" vim: set foldmethod=marker:

" =============================================================================
" Requirement Checks: {{{
" =============================================================================

function! s:VersionRequirement(val, min)
  for l:idx in range(0, len(a:min) - 1)
    let l:v = get(a:val, l:idx, 0)
    if l:v < a:min[l:idx]
      return 0
    elseif l:v > a:min[l:idx]
      return 1
    endif
  endfor
  return 1
endfunction

if has('python')
  redir => s:pyv
  silent python import platform; print(platform.python_version())
  redir END

  let s:python26 = s:VersionRequirement(
        \ map(split(split(s:pyv)[0], '\.'), 'str2nr(v:val)'), [2, 6])
else
  let s:python26 = 0
endif

if !empty(&runtimepath)
  let s:vimfiles = split(&runtimepath, ',')[0]
else
  echohl ErrorMsg
  echomsg 'Unable to determine runtime path for Vim.'
  echohl NONE
endif

" }}}
" =============================================================================
" Vim Plug: {{{
" =============================================================================

" Define the 'vimrc' autocmd group
augroup vimrc
  autocmd!
augroup END

if &compatible
  " vint: -ProhibitSetNoCompatible
  set nocompatible
  " vint: +ProhibitSetNoCompatible
endif
filetype off

" Install vim-plug if it isn't installed and call plug#begin() out of box
function! s:DownloadVimPlug()
  if !exists('s:vimfiles')
    return
  endif
  if empty(glob(s:vimfiles . '/autoload/plug.vim'))
    let l:plug_url = 'https://github.com/junegunn/vim-plug.git'
    let l:tmp = tempname()
    let l:new = l:tmp . '/plug.vim'

    try
      let l:out = system(printf('git clone --depth 1 %s %s', l:plug_url, l:tmp))
      if v:shell_error
        echohl ErrorMsg
        echomsg 'Error downloading vim-plug: ' . l:out
        echohl NONE
        return
      endif

      if !isdirectory(s:vimfiles . '/autoload')
        call mkdir(s:vimfiles . '/autoload', 'p')
      endif
      call rename(l:new, s:vimfiles . '/autoload/plug.vim')

      " Install plugins at first
      autocmd vimrc VimEnter * PlugInstall | quit
    finally
      if isdirectory(l:tmp)
        let l:dir = '"' . escape(l:tmp, '"') . '"'
        silent call system((has('win32') ? 'rmdir /S /Q ' : 'rm -rf ') . l:dir)
      endif
    endtry
  endif
  call plug#begin(s:vimfiles . '/plugged')
endfunction

call s:DownloadVimPlug()

" Colorscheme
Plug 'yous/vim-open-color'

" General
" Preserve missing EOL at the end of text files
Plug 'yous/PreserveNoEOL'
" EditorConfig
if executable('editorconfig') == 1 || has('python3') || s:python26
  Plug 'editorconfig/editorconfig-vim'
endif
if !has('win32')
  if !has('win32unix') &&
        \ (v:version >= 704 || v:version == 703 && has('patch598')) &&
        \ executable('cmake') && (has('python3') || s:python26)
    function! s:BuildYCM(info)
      " info is a dictionary with 3 fields
      " - name: name of the plugin
      " - status: 'installed', 'updated', or 'unchanged'
      " - force: set on PlugInstall! or PlugUpdate!
      if a:info.status ==# 'installed' || a:info.force
        let l:options = []
        let l:requirements = [['clang', '--clang-completer'],
              \ ['go', '--gocode-completer'],
              \ ['cargo', '--racer-completer']]
        for l:r in l:requirements
          if executable(l:r[0])
            let l:options += [l:r[1]]
          endif
        endfor
        execute '!./install.py ' . join(l:options, ' ')
      endif
    endfunction

    " A code-completion engine for Vim
    let g:BuildYCMRef = function('s:BuildYCM')
    Plug 'Valloric/YouCompleteMe', { 'do': g:BuildYCMRef }
    unlet g:BuildYCMRef
    " Generates config files for YouCompleteMe
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
  endif
  if $MSYSTEM !=# 'MSYS' || executable('go')
    " A command-line fuzzy finder written in Go
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
  endif
  " A Vim plugin for looking up words in an online thesaurus
  Plug 'beloglazov/vim-online-thesaurus'
endif
" Directory viewer for Vim
Plug 'justinmk/vim-dirvish'
" Go to Terminal or File manager
Plug 'justinmk/vim-gtfo'
" Autocomplete if end
Plug 'tpope/vim-endwise'
" Vim sugar for the UNIX shell commands
Plug 'tpope/vim-eunuch'
if has('timers') && exists('*job_start') && exists('*ch_close_in')
  " Asynchronous Lint Engine
  Plug 'w0rp/ale'
else
  " Syntax checking plugin
  Plug 'vim-syntastic/syntastic'
endif
" Automated tag file generation and syntax highlighting of tags
if executable('ctags')
  Plug 'xolox/vim-misc' |
  Plug 'xolox/vim-shell' |
  Plug 'xolox/vim-easytags'
endif
" Vim Git runtime files
Plug 'tpope/vim-git'
" Git wrapper
Plug 'tpope/vim-fugitive'
" A git commit browser, requires tpope/vim-fugitive
Plug 'junegunn/gv.vim'
" Run interactive commands inside a Vim buffer
Plug 'yous/conque', { 'on': [
      \ 'ConqueTerm',
      \ 'ConqueTermSplit',
      \ 'ConqueTermVSplit',
      \ 'ConqueTermTab'] }

" Motions and text changing
" Provide CamelCase motion through words
Plug 'bkad/CamelCaseMotion'
" Vim motions on speed!
Plug 'easymotion/vim-easymotion'
" Extended % matching for HTML, LaTeX, and many other languages
Plug 'tmhedberg/matchit'
" Simplify the transition between multiline and single-line code
Plug 'AndrewRadev/splitjoin.vim'
" Easily delete, change and add surroundings in pairs
Plug 'tpope/vim-surround'
" Pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'
if v:version >= 700
  " Produce increasing/decreasing columns of numbers, dates, or daynames
  Plug 'vim-scripts/VisIncr'
endif
" Switch between source files and header files
Plug 'vim-scripts/a.vim'
" Enable repeating supported plugin maps with "."
Plug 'tpope/vim-repeat'

" Vim UI
" A light and configurable statusline/tabline for Vim
Plug 'itchyny/lightline.vim'
" Simpler Rainbow Parentheses
Plug 'junegunn/rainbow_parentheses.vim', { 'for': [
      \ 'clojure',
      \ 'lisp',
      \ 'racket',
      \ 'scheme'] }
if has('signs')
  " Show a git diff in the gutter and stages/reverts hunks
  Plug 'airblade/vim-gitgutter'
endif
" Distraction-free writing in Vim
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }

" Support file types
" AdBlock
Plug 'yous/adblock-filter.vim', {
      \ 'branch': 'nocindent',
      \ 'for': 'adblockfilter' }
" Aheui
Plug 'yous/aheui.vim', { 'for': 'aheui' }
" CUP
Plug 'gcollura/cup.vim', { 'for': 'cup' }
" GNU As
Plug 'Shirk/vim-gas', { 'for': 'gas' }
" Jade
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
" JSON
Plug 'elzr/vim-json', { 'for': ['json', 'markdown'] }
" LaTeX
Plug 'lervag/vimtex', { 'for': ['bib', 'tex'] }
" Markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' } |
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
" PHP
Plug 'vim-scripts/php.vim-html-enhanced', { 'for': ['html', 'php'] }
" Racket
Plug 'wlangstroth/vim-racket', { 'for': 'racket' }
" smali
Plug 'kelwin/vim-smali', { 'for': 'smali' }
" SMT-LIB
Plug 'raichoo/smt-vim', { 'for': 'smt' }
" Vader
Plug 'junegunn/vader.vim', { 'for': 'vader' }
" XML
Plug 'othree/xml.vim', { 'for': 'xml' }
" A solid language pack for Vim
Plug 'sheerun/vim-polyglot'

" Python
" A nicer Python indentation style for vim
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }

" Ruby
" Rake
Plug 'tpope/vim-rake'
" RuboCop
Plug 'ngmy/vim-rubocop', { 'on': 'RuboCop' }
" Rails
Plug 'tpope/vim-rails'
if v:version >= 700
  " ANSI escape sequences concealed, but highlighted as specified (conceal)
  Plug 'powerman/vim-plugin-AnsiEsc', { 'for': 'railslog' }
endif
" TomDoc
Plug 'wellbredgrapefruit/tomdoc.vim', { 'for': 'ruby' }

" Mac OS
if has('mac') || has('macunix')
  " Add plist editing support to Vim
  Plug 'darfink/vim-plist'
  " Launch queries for Dash.app from inside Vim
  Plug 'rizzatti/dash.vim', { 'on': [
        \ 'Dash',
        \ 'DashKeywords',
        \ '<Plug>DashSearch',
        \ '<Plug>DashGlobalSearch'] }
endif

call plug#end()
" Followings are done by `plug#end()`:
" filetype plugin indent on
" syntax on

" }}}
" =============================================================================
" General: {{{
" =============================================================================

if &shell =~# 'fish$'
  set shell=sh
endif
if has('gui_running')
  language messages en
  if has('multi_byte')
    set encoding=utf-8
    scriptencoding utf-8
  endif
endif
set autoread
set background=dark
set backspace=indent,eol,start
" Use the clipboard register '*'
set clipboard=unnamed
if has('multi_byte')
  set fileencodings=ucs-bom,utf-8,cp949,latin1
endif
set fileformats=unix,mac,dos
if has('folding')
  " Sets 'foldlevel' when starting to edit another buffer in a window
  set foldlevelstart=99
endif
" Number of remembered ":" commands
set history=1000
" Ignore case in search
set ignorecase
if has('extra_search')
  " Show where the pattern while typing a search command
  set incsearch
endif
" Don't make a backup before overwriting a file
set nobackup
" Override the 'ignorecase' if the search pattern contains upper case
set smartcase
" Enable list mode
set list
" Strings to use in 'list' mode and for the :list command
try
  set listchars=tab:>\ ,trail:·,extends:»,precedes:«,nbsp:+
catch /^Vim\%((\a\+)\)\=:E474/
  set listchars=tab:>\ ,trail:_,extends:>,precedes:<,nbsp:+
endtry
" The key sequence that toggles the 'paste' option
set pastetoggle=<F2>
" Maximum number of changes that can be undone
set undolevels=1000
" Update swap file and trigger CursorHold after 1 second
set updatetime=1000
if has('wildignore')
  " List of file patterns to ignore when expanding wildcards, completing file or
  " directory names, and influences the result of expand(), glob() and
  " globpath()
  set wildignore+=.git,.hg,.svn
  set wildignore+=*.bmp,*.gif,*.jpeg,*.jpg,*.png
  set wildignore+=*.dll,*.exe,*.o,*.obj
  set wildignore+=*.sw?
  set wildignore+=*.DS_Store
  set wildignore+=*.pyc
endif
if exists('+wildignorecase')
  " Ignore case when completing file names and directories
  set wildignorecase
endif
if has('wildmenu')
  " Enhanced command-line completion
  set wildmenu
endif

if has('win32')
  " Directory names for the swap file
  set directory=.,$TEMP
  " Use a forward slash when expanding file names
  set shellslash
endif

" }}}
" =============================================================================
" Vim UI: {{{
" =============================================================================

try
  colorscheme open-color
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry

if has('syntax') && has('gui_running') && &t_Co > 16
  " Highlight the screen line of the cursor
  set cursorline
endif
" Show as much as possible of the last line
set display+=lastline
" Show unprintable characters as a hex number
set display+=uhex
if has('extra_search')
  set hlsearch
endif
" Always show a status line
set laststatus=2
set number
" Don't consider octal number when using the CTRL-A and CTRL-X commands
set nrformats-=octal
set scrolloff=3
if has('cmdline_info')
  " Show command in the last line of the screen
  set showcmd
endif
" Briefly jump to the matching one when a bracket is inserted
set showmatch
" The minimal number of columns to scroll horizontally
set sidescroll=1
set sidescrolloff=10
if has('windows')
  set splitbelow
endif
if has('vertsplit')
  set splitright
endif
if empty($TMUX) && empty($STY) && has('termguicolors') &&
      \ exists('g:colors_name') && g:colors_name !=# 'default'
  if !has('mac') || $TERM_PROGRAM ==# 'iTerm.app'
    set termguicolors
  endif
endif

augroup colorcolumn
  autocmd!
  if exists('+colorcolumn')
    " Highlight column after 'textwidth'
    set colorcolumn=+1
  else
    autocmd BufWinEnter *
          \ let w:m2 = matchadd('ErrorMsg', '\%' . (&textwidth + 1) . 'v', -1)
  endif
augroup END

" Highlight trailing whitespace
function! s:MatchExtraWhitespace(enabled)
  if a:enabled && index(['GV', 'conque_term', 'vim-plug'], &filetype) < 0
    match ExtraWhitespace /\s\+$/
  else
    match ExtraWhitespace //
  endif
endfunction
highlight ExtraWhitespace ctermbg=red guibg=red
augroup ExtraWhitespace
  autocmd!
  autocmd BufWinEnter * call s:MatchExtraWhitespace(1)
  autocmd FileType * call s:MatchExtraWhitespace(1)
  autocmd InsertEnter * call s:MatchExtraWhitespace(0)
  autocmd InsertLeave * call s:MatchExtraWhitespace(1)
  if v:version >= 702
    autocmd BufWinLeave * call clearmatches()
  endif
augroup END

" }}}
" =============================================================================
" GUI: {{{
" =============================================================================

if has('gui_running')
  set guifont=Consolas:h10:cANSI
  set guioptions-=m " Menu bar
  set guioptions-=T " Toolbar
  set guioptions-=r " Right-hand scrollbar
  set guioptions-=L " Left-hand scrollbar when window is vertically split

  source $VIMRUNTIME/delmenu.vim
  source $VIMRUNTIME/menu.vim

  if has('win32')
    set guifontwide=D2Coding:h10:cDEFAULT,
          \NanumGothicCoding:h10:cDEFAULT,
          \DotumChe:h10:cDEFAULT
  endif

  function! s:ScreenFilename()
    if has('amiga')
      return 's:.vimsize'
    elseif has('win32')
      return $HOME . '\_vimsize'
    else
      return $HOME . '/.vimsize'
    endif
  endfunction
  function! s:ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let l:f = s:ScreenFilename()
    if has('gui_running') && g:screen_size_restore_pos && filereadable(l:f)
      let l:vim_instance =
            \ (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      for l:line in readfile(l:f)
        let l:sizepos = split(l:line)
        if len(l:sizepos) == 5 && l:sizepos[0] == l:vim_instance
          silent! execute 'set columns=' . l:sizepos[1] .
                \ ' lines=' . l:sizepos[2]
          silent! execute 'winpos ' . l:sizepos[3] . ' ' . l:sizepos[4]
          return
        endif
      endfor
    endif
  endfunction
  function! s:ScreenSave()
    " Save window size and position.
    if has('gui_running') && g:screen_size_restore_pos
      let l:vim_instance =
            \ (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      let l:data = l:vim_instance . ' ' . &columns . ' ' . &lines . ' ' .
            \ (getwinposx() < 0 ? 0: getwinposx()) . ' ' .
            \ (getwinposy() < 0 ? 0: getwinposy())
      let l:f = s:ScreenFilename()
      if filereadable(l:f)
        let l:lines = readfile(l:f)
        call filter(l:lines, "v:val !~ '^" . l:vim_instance . "\\>'")
        call add(l:lines, l:data)
      else
        let l:lines = [l:data]
      endif
      call writefile(l:lines, l:f)
    endif
  endfunction
  if !exists('g:screen_size_restore_pos')
    let g:screen_size_restore_pos = 1
  endif
  if !exists('g:screen_size_by_vim_instance')
    let g:screen_size_by_vim_instance = 1
  endif
  augroup ScreenRestore
    autocmd!
    autocmd VimEnter *
          \ if g:screen_size_restore_pos == 1 |
          \   call s:ScreenRestore() |
          \ endif
    autocmd VimLeavePre *
          \ if g:screen_size_restore_pos == 1 |
          \   call s:ScreenSave() |
          \ endif
  augroup END
endif

" }}}
" =============================================================================
" Text Formatting: {{{
" =============================================================================

set autoindent
if has('cindent')
  set cindent
endif
set expandtab
" Insert only one space after a '.', '?' and '!' with a join command
set nojoinspaces
" Number of spaces that a <Tab> counts for while editing
set softtabstop=2
" Number of spaces to use for each setp of (auto)indent
set shiftwidth=2
" Number of spaces that a <Tab> in the file counts for
set tabstop=8
" Maximum width of text that is being inserted
set textwidth=80
autocmd vimrc FileType c,cpp,java,json,markdown,perl,python
      \ setlocal softtabstop=4 shiftwidth=4
autocmd vimrc FileType gitconfig
      \ setlocal noexpandtab softtabstop=8 shiftwidth=8
autocmd vimrc FileType go
      \ setlocal noexpandtab softtabstop=4 shiftwidth=4 tabstop=4
" t: Auto-wrap text using textwidth
" c: Auto-wrap comments using textwidth
" r: Automatically insert the current comment leader after hitting <Enter> in
"    Insert mode
" o: Automatically insert the current comment leader after hitting 'o' or 'O' in
"    Normal mode
" q: Allow formatting of comments with "gq"
" l: Long lines are not broken in insert mode
" j: Remove a comment leader when joining lines
autocmd vimrc FileType *
      \ setlocal formatoptions+=c
      \   formatoptions+=r
      \   formatoptions+=q
      \   formatoptions+=l |
      \ if &filetype ==# 'markdown' |
      \   setlocal formatoptions+=o |
      \ else |
      \   setlocal formatoptions-=o |
      \ endif |
      \ if index(['gitcommit', 'markdown', 'tex'], &filetype) < 0 |
      \   setlocal formatoptions-=t |
      \ endif |
      \ if v:version >= 704 || v:version == 703 && has('patch541') |
      \   setlocal formatoptions+=j |
      \ endif

" }}}
" =============================================================================
" Mappings: {{{
" =============================================================================

" Commander
nnoremap ; :

" We do line wrap
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
noremap gj j
noremap gk k

" Easy navigation on a line
noremap H ^
noremap L $

" Unix shell behavior
inoremap <C-A> <Esc>I
inoremap <C-E> <Esc>A
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" Leave insert mode
function! s:CtrlL()
  " Keep the original feature of CTRL-L. See :help i_CTRL-L.
  if exists('&insertmode') && &insertmode
    call feedkeys("\<C-L>", 'n')
  else
    call feedkeys("\e", 't')
  endif
endfunction
inoremap <silent> <C-L> <C-O>:call <SID>CtrlL()<CR>

" Make Y behave like C and D
nnoremap Y y$

" Delete without copying
vnoremap <BS> "_d

" Break the undo block when CTRL-U
inoremap <C-U> <C-G>u<C-U>

if has('wildmenu')
  " Move into subdirectory in wildmenu
  function! s:WildmenuEnterSubdir()
    call feedkeys("\<Down>", 't')
    return ''
  endfunction
  cnoremap <expr> <C-J> <SID>WildmenuEnterSubdir()
endif

" Move cursor between splitted windows
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l

" Reselect visual block after shifting
vnoremap < <gv
vnoremap > >gv

" Search regex
" All ASCII characters except 0-9, a-z, A-Z and '_' have a special meaning
nnoremap / /\v
vnoremap / /\v
cnoremap %s/ %smagic/
cnoremap \>s/ \>smagic/

" Use CTRL-N to clear the highlighting and screen
nnoremap <silent> <C-N> :nohlsearch<C-R>=has('diff') ? '<Bar>diffupdate' : ''<CR><CR><C-L>

" Search for visually selected text
function! s:VSearch(cmd)
  let l:old_reg = getreg('"')
  let l:old_regtype = getregtype('"')
  normal! gvy
  let l:pat = escape(@", a:cmd . '\')
  let l:pat = substitute(l:pat, '\n', '\\n', 'g')
  let @/ = '\V' . l:pat
  normal! gV
  call setreg('"', l:old_reg, l:old_regtype)
endfunction
vnoremap * :<C-U>call <SID>VSearch('/')<CR>/<C-R>/<CR>
vnoremap # :<C-U>call <SID>VSearch('?')<CR>?<C-R>/<CR>

" Center display after searching
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Execute @q which is recorded by qq
nnoremap Q @q

" Zoom and restore window
function! s:ZoomToggle()
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  elseif tabpagewinnr(tabpagenr('$'), '$') > 1
    " Resize only when multiple windows are in the current tab page
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction
nnoremap <silent> <Leader>z :call <SID>ZoomToggle()<CR>

" Cscope mappings
if has('cscope')
  function! s:FindCscopeDB()
    let l:db = findfile('cscope.out', '.;')
    if !empty(l:db)
      silent cscope reset
      silent! execute 'cscope add' l:db
    elseif !empty($CSCOPE_DB)
      silent cscope reset
      silent! execute 'cscope add' $CSCOPE_DB
    endif
  endfunction

  set cscopetag
  set cscopetagorder=0
  set cscopeverbose
  call s:FindCscopeDB()

  " 0 or s: Find this C symbol
  " 1 or g: Find this definition
  " 2 or d: Find functions called by this function
  " 3 or c: Find functions calling this function
  " 4 or t: Find this text string
  " 6 or e: Find this egrep pattern
  " 7 or f: Find this file
  " 8 or i: Find files #including this file
  " 9 or a: Find places where this symbol is assigned a value
  nnoremap <C-\>s :cscope find s <C-R>=expand('<cword>')<CR><CR>
  nnoremap <C-\>g :cscope find g <C-R>=expand('<cword>')<CR><CR>
  nnoremap <C-\>d :cscope find d <C-R>=expand('<cword>')<CR><CR>
  nnoremap <C-\>c :cscope find c <C-R>=expand('<cword>')<CR><CR>
  nnoremap <C-\>t :cscope find t <C-R>=expand('<cword>')<CR><CR>
  xnoremap <C-\>t y:cscope find t <C-R>"<CR>
  nnoremap <C-\>e :cscope find e <C-R>=expand('<cword>')<CR><CR>
  nnoremap <C-\>f :cscope find f <C-R>=expand('<cfile>')<CR><CR>
  nnoremap <C-\>i :cscope find i ^<C-R>=expand('<cfile>')<CR>$<CR>
  nnoremap <C-\>a :cscope find a <C-R>=expand('<cword>')<CR><CR>
endif

augroup vimrc
  " Quit help window
  autocmd FileType help nnoremap <buffer> q :q<CR>

  " Quit quickfix window
  autocmd FileType qf nnoremap <buffer> q :q<CR>

  " C, C++ compile
  autocmd FileType c,cpp nnoremap <buffer> <F5> :w<CR>:make %<CR>
  autocmd FileType c,cpp inoremap <buffer> <F5> <Esc>:w<CR>:make %<CR>
  autocmd FileType c
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   setlocal makeprg=gcc\ -o\ %< |
        \ endif
  autocmd FileType cpp
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   setlocal makeprg=g++\ -o\ %< |
        \ endif

  " Markdown code snippets
  autocmd FileType markdown inoremap <buffer> <LocalLeader>` ```

  " Go
  autocmd FileType go nnoremap <buffer> <F5> :w<CR>:!go run %<CR>
  autocmd FileType go inoremap <buffer> <F5> <Esc>:w<CR>:!go run %<CR>

  " Python
  autocmd FileType python nnoremap <buffer> <F5> :w<CR>:!python %<CR>
  autocmd FileType python inoremap <buffer> <F5> <Esc>:w<CR>:!python %<CR>

  " Ruby
  autocmd FileType ruby nnoremap <buffer> <F5> :w<CR>:!ruby %<CR>
  autocmd FileType ruby inoremap <buffer> <F5> <Esc>:w<CR>:!ruby %<CR>
augroup END

" File execution
if has('win32')
  nnoremap <F6> :!%<.exe<CR>
  inoremap <F6> <Esc>:!%<.exe<CR>
elseif has('unix')
  nnoremap <F6> :!./%<<CR>
  inoremap <F6> <Esc>:!./%<<CR>
endif

" }}}
" =============================================================================
" Functions And Commands: {{{
" =============================================================================

" Auto quit Vim when actual files are closed
function! s:CheckLeftBuffers()
  if tabpagenr('$') == 1
    let l:i = 1
    while l:i <= winnr('$')
      let l:filetypes = ['help', 'quickfix', 'nerdtree', 'taglist']
      if index(l:filetypes, getbufvar(winbufnr(l:i), '&filetype')) >= 0 ||
            \ getwinvar(l:i, '&previewwindow')
        let l:i += 1
      else
        break
      endif
    endwhile
    if l:i == winnr('$') + 1
      call feedkeys(":only\<CR>:q\<CR>", 'n')
    endif
  endif
endfunction
autocmd vimrc BufEnter * call s:CheckLeftBuffers()

if has('win32')
  command! Gdiffs cexpr system('git diff \| diff-hunk-list.bat') |
        \ cwindow | wincmd p
else
  command! Gdiffs cexpr system('git diff \| diff-hunk-list') |
        \ cwindow | wincmd p
endif

" }}}
" =============================================================================
" Autocmd: {{{
" =============================================================================

augroup vimrc
  " Reload vimrc on the fly
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC

  " Exit Paste mode when leaving Insert mode
  autocmd InsertLeave * set nopaste

  " Check if any buffers were changed outside of Vim
  autocmd FocusGained,BufEnter * checktime

  " Keyword lookup program
  autocmd FileType c,cpp setlocal keywordprg=man
  autocmd FileType gitconfig
        \ setlocal keywordprg=man\ git-config\ \|\ less\ -i\ -p
  autocmd FileType help,vim setlocal keywordprg=:help
  autocmd FileType ruby setlocal keywordprg=ri

  " Plain view for plugins
  autocmd FileType GV,conque_term,vim-plug
        \ setlocal colorcolumn= nolist textwidth=0

  " Ruby configuration files view
  autocmd BufNewFile,BufRead Gemfile,Guardfile setlocal filetype=ruby

  " Gradle view
  autocmd BufNewFile,BufRead *.gradle setlocal filetype=groovy

  " Json view
  autocmd BufNewFile,BufRead *.json setlocal filetype=json

  " Markdown view
  autocmd BufNewFile,BufRead *.md setfiletype markdown

  " mobile.erb view
  autocmd BufNewFile,BufRead *.mobile.erb let b:eruby_subtype = 'html'
  autocmd BufNewFile,BufRead *.mobile.erb setfiletype eruby

  " zsh-theme view
  autocmd BufNewFile,BufRead *.zsh-theme setlocal filetype=zsh
augroup END

" Reload symlink of vimrc on the fly
let s:resolved_vimrc = resolve(expand($MYVIMRC))
if expand($MYVIMRC) !=# s:resolved_vimrc
  execute 'autocmd vimrc BufWritePost ' . s:resolved_vimrc .
        \ ' nested source $MYVIMRC'
endif
unlet s:resolved_vimrc

" }}}
" =============================================================================
" Plugins: {{{
" =============================================================================

" PreserveNoEOL
let g:PreserveNoEOL = 1

" EditorConfig
if executable('editorconfig')
  let g:EditorConfig_core_mode = 'external_command'
endif

" YouCompleteMe
let g:ycm_filetype_blacklist = {
      \ 'diff': 1,
      \ 'infolog': 1,
      \ 'mail': 1,
      \ 'markdown': 1,
      \ 'netrw': 1,
      \ 'notes': 1,
      \ 'pandoc': 1,
      \ 'qf': 1,
      \ 'tagbar': 1,
      \ 'text': 1,
      \ 'unite': 1,
      \ 'vimwiki': 1 }
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
if exists('s:vimfiles')
  let g:ycm_global_ycm_extra_conf = s:vimfiles .
        \ '/plugged/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
endif
let g:ycm_confirm_extra_conf = 0

" ale
if has_key(g:plugs, 'ale')
  let g:ale_echo_msg_error_str = 'E'
  let g:ale_echo_msg_warning_str = 'W'
  let g:ale_echo_msg_format = '[%linter%][%severity%] %s'
  let g:ale_lint_on_save = 1
  let g:ale_lint_on_text_changed = 0
  let g:ale_statusline_format = ['%d error(s)', '%d warning(s)', '']
  let g:ale_ruby_rubocop_options = '--display-cop-names'
endif

" Syntastic
if has_key(g:plugs, 'syntastic')
  " Skip checks when you issue :wq, :x and :ZZ
  let g:syntastic_check_on_wq = 0
  " Display all of the errors from all of the checkers together
  let g:syntastic_aggregate_errors = 1
  " Sort errors by file, line number, type, column number
  let g:syntastic_sort_aggregated_errors = 1
  " Turn off highlighting for marking errors
  let g:syntastic_enable_highlighting = 0
  " Always stick any detected errors into the location-list
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_mode_map = { 'mode': 'passive' }
  " Check header files
  let g:syntastic_c_check_header = 1
  let g:syntastic_cpp_check_header = 1
  " Enable JSCS for JavaScript files
  let g:syntastic_javascript_checkers = ['jshint', 'jslint', 'jscs']
  " Extend max error count for JSLint
  let g:syntastic_javascript_jslint_args = '--white --nomen --regexp --plusplus
        \ --bitwise --newcap --sloppy --vars --maxerr=1000'
  " Enable Vint for Vim files
  let g:syntastic_javascript_checkers = ['vimlint', 'vint']
endif

" vim-shell
let g:shell_hl_exclude = '^.*$'
let g:shell_mappings_enabled = 0

" vim-easytags
let g:easytags_auto_highlight = 0
let g:easytags_async = 1
let g:easytags_dynamic_files = 1

" Fugitive
let s:fugitive_insert = 0
augroup Fugitive
  autocmd!
  autocmd FileType gitcommit
        \ if byte2line(2) == 2 |
        \   let s:fugitive_insert = 1 |
        \ endif
  autocmd VimEnter *
        \ if (s:fugitive_insert) |
        \   startinsert |
        \ endif
augroup END

" ConqueTerm
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_ReadUnfocused = 1
command! -nargs=* Sh ConqueTerm <args>
command! -nargs=* Shsp ConqueTermSplit <args>
command! -nargs=* Shtab ConqueTermTab <args>
command! -nargs=* Shvs ConqueTermVSplit <args>

" CamelCaseMotion
function! s:CreateCamelCaseMotionMappings()
  for l:mode in ['n', 'o', 'x']
    for l:motion in ['w', 'b', 'e']
      let l:target_mapping = '<Plug>CamelCaseMotion_' . l:motion
      execute l:mode . 'map <silent> <Leader><Leader>' . l:motion . ' '
            \ . l:target_mapping
    endfor
  endfor
endfunction
call s:CreateCamelCaseMotionMappings()

" EasyMotion
map <Leader> <Plug>(easymotion-prefix)

" unimpaired.vim
" Center display on move between SCM conflicts
nnoremap [n [nzz
nnoremap ]n ]nzz

" lightline.vim
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['filename', 'readonly', 'eol', 'modified']],
      \   'right': [
      \     [has_key(g:plugs, 'ale') ? 'ale' : 'syntastic', 'lineinfo'],
      \     ['percent'],
      \     ['filetype', 'fileencoding', 'fileformat']] },
      \ 'tabline': { 'left': [['tabs']], 'right': [[]] },
      \ 'tab': {
      \   'active': ['tabfilename', 'tabmodified'],
      \   'inactive': ['tabfilename', 'tabmodified'] },
      \ 'component_function': {},
      \ 'tab_component_function': {},
      \ 'component_expand': {
      \   'readonly': 'LightLineReadonly',
      \   'eol': 'LightLineEol',
      \   'ale': 'ALEGetStatusLine',
      \   'syntastic': 'SyntasticStatuslineFlag' },
      \ 'component_type': {
      \   'readonly': 'warning',
      \   'eol': 'warning',
      \   'ale': 'error',
      \   'syntastic': 'error' },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '|' } }

for s:k in ['mode', 'filename', 'modified', 'filetype', 'fileencoding',
      \ 'fileformat', 'percent', 'lineinfo']
  let g:lightline.component_function[s:k] =
        \ 'LightLine' . toupper(s:k[0]) . s:k[1:]
endfor
for s:k in ['filename', 'modified']
  let g:lightline.tab_component_function['tab' . s:k] =
        \ 'LightLineTab' . toupper(s:k[0]) . s:k[1:]
endfor

function! LightLineWide(component)
  let l:component_visible_width = {
        \ 'mode': 60,
        \ 'fileencoding': 70,
        \ 'fileformat': 70,
        \ 'filetype': 70,
        \ 'percent': 50 }
  return winwidth(0) >= get(l:component_visible_width, a:component, 0)
endfunction

function! LightLineVisible(component)
  let l:fname = expand('%:t')
  return l:fname !=# '__Tag_List__' &&
        \ l:fname !=# 'ControlP' &&
        \ l:fname !~# 'NERD_tree' &&
        \ LightLineWide(a:component)
endfunction

function! LightLineMode()
  let l:short_mode_map = {
        \ 'n': 'N',
        \ 'i': 'I',
        \ 'R': 'R',
        \ 'v': 'V',
        \ 'V': 'V',
        \ 'c': 'C',
        \ "\<C-v>": 'V',
        \ 's': 'S',
        \ 'S': 'S',
        \ "\<C-s>": 'S',
        \ 't': 'T',
        \ '?': ' ' }
  let l:fname = expand('%:t')
  return l:fname ==# '__Tag_List__' ? 'TagList' :
        \ l:fname ==# 'ControlP' ? 'CtrlP' :
        \ l:fname =~# 'NERD_tree' ? '' :
        \ LightLineWide('mode') ? lightline#mode() :
        \ get(l:short_mode_map, mode(), l:short_mode_map['?'])
endfunction

function! LightLineFilename()
  let l:fname = expand('%:t')
  return l:fname ==# '__Tag_List__' ? '' :
        \ l:fname ==# 'ControlP' ? '' :
        \ l:fname =~# 'NERD_tree' ?
        \   (index(['" Press ? for help', '.. (up a dir)'], getline('.')) < 0 ?
        \     matchstr(getline('.'), '[0-9A-Za-z_/].*') : '') :
        \ '' !=# l:fname ? l:fname : '[No Name]'
endfunction

function! LightLineReadonly()
  return &readonly ? 'RO' : ''
endfunction

function! LightLineEol()
  return &endofline ? '' : 'NOEOL'
endfunction

function! LightLineModified()
  return &modified ? '+' : ''
endfunction

function! LightLineFiletype()
  return LightLineVisible('filetype') ?
        \ (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return LightLineVisible('fileencoding') ?
        \ (strlen(&fileencoding) ? &fileencoding : &encoding) : ''
endfunction

function! LightLineFileformat()
  return LightLineVisible('fileformat') ? &fileformat : ''
endfunction

function! LightLinePercent()
  return LightLineVisible('percent') ? (100 * line('.') / line('$')) . '%' : ''
endfunction

function! LightLineLineinfo()
  return LightLineVisible('lineinfo') ?
        \ printf('%3d:%-2d', line('.'), col('.')) : ''
endfunction

function! LightLineTabFilename(n)
  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  let l:fname = expand('#' . l:buflist[l:winnr - 1] . ':t')
  let l:filetype = gettabwinvar(a:n, l:winnr, '&filetype')
  return l:filetype ==# 'GV' ? 'GV' :
        \ '' !=# l:fname ? l:fname : '[No Name]'
endfunction

function! LightLineTabModified(n)
  let l:winnr = tabpagewinnr(a:n)
  return gettabwinvar(a:n, l:winnr, '&modified') ? '+' : ''
endfunction

if has_key(g:plugs, 'ale')
  augroup LightLineALE
    autocmd!
    autocmd User ALELint call s:LightLineALE()
  augroup END

  function! s:LightLineALE()
    if exists('#lightline')
      call lightline#update()
    endif
  endfunction
endif

if has_key(g:plugs, 'syntastic')
  let g:lightline.syntastic_mode_active = 1
  augroup LightLineSyntastic
    autocmd!
    autocmd BufWritePost * call s:LightLineSyntastic()
  augroup END

  function! s:LightLineSyntastic()
    if g:lightline.syntastic_mode_active
      SyntasticCheck
      if exists('#lightline')
        call lightline#update()
      endif
    endif
  endfunction
  command! LightLineSyntastic call s:LightLineSyntastic()

  function! s:LightLineSyntasticToggleMode()
    if g:lightline.syntastic_mode_active
      let g:lightline.syntastic_mode_active = 0
      echo 'Syntastic: passive mode enabled'
    else
      let g:lightline.syntastic_mode_active = 1
      echo 'Syntastic: active mode enabled'
    endif
    SyntasticReset
  endfunction
  command! LightLineSyntasticToggleMode call s:LightLineSyntasticToggleMode()
endif

" rainbow_parentheses.vim
autocmd vimrc FileType clojure,lisp,racket,scheme RainbowParentheses

" goyo.vim
nnoremap <Leader>G :Goyo<CR>

" Adblock
let g:adblock_filter_auto_checksum = 1

" vim-json
let g:vim_json_syntax_conceal = 0

" vimtex
if has('win32unix')
  let g:vimtex_complete_enabled = 0
  let g:vimtex_latexmk_enabled = 0
  let g:vimtex_view_enabled = 0
endif
if !has('clientserver')
  let g:vimtex_latexmk_callback = 0
endif
if !empty(glob('/Applications/Skim.app'))
  let g:vimtex_view_general_viewer =
        \ '/Applications/Skim.app/Contents/SharedSupport/displayline'
  let g:vimtex_view_general_options = '-r @line @pdf @tex'
elseif executable('SumatraPDF.exe')
  let g:vimtex_view_general_viewer = 'SumatraPDF'
  let g:vimtex_view_general_options =
        \ '-reuse-instance -forward-search @tex @line @pdf'
  let g:vimtex_view_general_options_latexmk = '-reuse-instance'
endif
let g:vimtex_syntax_minted = [
      \ {
      \   'lang': 'c'
      \ },
      \ {
      \   'lang': 'cpp'
      \ },
      \ {
      \   'lang': 'python'
      \ },
      \ {
      \   'lang': 'ruby'
      \ }]

" vim-markdown
let g:vim_markdown_fenced_languages = [
      \ 'bat=dosbatch', 'batch=dosbatch',
      \ 'coffeescript=coffee',
      \ 'c++=cpp',
      \ 'csharp=cs',
      \ 'dockerfile=Dockerfile',
      \ 'erb=eruby',
      \ 'ini=dosini',
      \ 'js=javascript',
      \ 'rb=ruby',
      \ 'bash=sh',
      \ 'viml=vim']
let g:vim_markdown_frontmatter = 1
nnoremap <Plug> <Plug>Markdown_EditUrlUnderCursor
vnoremap <Plug> <Plug>Markdown_EditUrlUnderCursor
nnoremap <Plug> <Plug>Markdown_MoveToCurHeader
vnoremap <Plug> <Plug>Markdown_MoveToCurHeader

" vim-polyglot
let g:polyglot_disabled = ['json', 'latex', 'markdown', 'python']
" vim-javascript
let g:javascript_plugin_jsdoc = 1

" vim-rake
nnoremap <Leader>ra :Rake<CR>

" vim-rubocop
let g:vimrubocop_extra_args = '--display-cop-names'
let g:vimrubocop_keymap = 0
nnoremap <Leader>ru :RuboCop<CR>

" AnsiEsc.vim
autocmd vimrc FileType railslog :AnsiEsc

" Mac OS
if has('mac') || has('macunix')
  " dash.vim
  let g:dash_map = {
        \ 'java' : 'android' }
  nnoremap <Leader>d <Plug>DashSearch
endif

" }}}
" =============================================================================
