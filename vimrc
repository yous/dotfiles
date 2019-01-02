" vim: set foldmethod=marker:

if &compatible
  " vint: -ProhibitSetNoCompatible
  set nocompatible
  " vint: +ProhibitSetNoCompatible
endif

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

if has('nvim') && executable('pyenv')
  if executable($HOME . '/.pyenv/versions/neovim2/bin/python')
    let g:python_host_prog = $HOME . '/.pyenv/versions/neovim2/bin/python'
  endif
  if executable($HOME . '/.pyenv/versions/neovim3/bin/python')
    let g:python3_host_prog = $HOME . '/.pyenv/versions/neovim3/bin/python'
  endif
endif

if has('python')
  redir => s:pyv
  silent python import platform; print(platform.python_version())
  redir END

  let s:python26 = s:VersionRequirement(
        \ map(split(split(s:pyv)[0], '\.'), 'str2nr(v:val)'), [2, 6])
else
  let s:python26 = 0
endif

if has('python3') && !has('patch-8.1.201')
  silent! python3 1
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

filetype off

" Install vim-plug if it isn't installed
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
    finally
      if isdirectory(l:tmp)
        let l:dir = '"' . escape(l:tmp, '"') . '"'
        silent call system((has('win32') ? 'rmdir /S /Q ' : 'rm -rf ') . l:dir)
      endif
    endtry
  endif
endfunction

call s:DownloadVimPlug()
call plug#begin(s:vimfiles . '/plugged')

" Colorscheme
Plug 'yous/vim-open-color'

" General
" Preserve missing EOL at the end of text files
Plug 'yous/PreserveNoEOL', {
      \ 'commit': '9ef2f01',
      \ 'frozen': 1 }
" Yet another EditorConfig plugin for vim written in vimscript only
Plug 'sgur/vim-editorconfig'
" sleuth.vim: Heuristically set buffer options
Plug 'tpope/vim-sleuth'
" A Plugin to show a diff, whenever recovering a buffer
Plug 'chrisbra/Recover.vim'
" obsession.vim: continuously updated session files
Plug 'tpope/vim-obsession'
" Vim sugar for the UNIX shell commands
Plug 'tpope/vim-eunuch'
" A Vim plugin that manages your tag files
if executable('ctags') || executable('cscope')
  if v:version >= 800
    Plug 'ludovicchabant/vim-gutentags'
  elseif v:version >= 704
    Plug 'ludovicchabant/vim-gutentags', { 'branch': 'vim7' }
  endif
endif
" Vim Git runtime files
Plug 'tpope/vim-git'
" Git wrapper
Plug 'tpope/vim-fugitive'
" A git commit browser
" Plug 'tpope/vim-fugitive' |
Plug 'junegunn/gv.vim'

" Browsing
if !has('win32') && (!has('win32unix') || executable('go'))
  " A command-line fuzzy finder written in Go
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
endif
" Directory viewer for Vim
Plug 'justinmk/vim-dirvish'
if !has('nvim')
  " Tab-specific directories
  Plug 'vim-scripts/tcd.vim'
endif
" Go to Terminal or File manager
Plug 'justinmk/vim-gtfo'

" Completion and lint
if !has('win32')
  if !has('win32unix') &&
        \ has('patch-7.4.1578') &&
        \ executable('cmake') && (has('python3') || s:python26)
    function! s:BuildYCM(info)
      " info is a dictionary with 3 fields
      " - name: name of the plugin
      " - status: 'installed', 'updated', or 'unchanged'
      " - force: set on PlugInstall! or PlugUpdate!
      if a:info.status ==# 'installed' || a:info.force
        let l:options = []
        let l:requirements = [
              \ ['clang', '--clang-completer'],
              \ ['mono', '--cs-completer'],
              \ ['go', '--go-completer'],
              \ ['cargo', '--rust-completer']]
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
endif
" Print documents in echo area
if exists('v:completed_item')
  Plug 'Shougo/echodoc.vim'
endif
if has('nvim') && has('timers') ||
      \ has('timers') && exists('*job_start') && exists('*ch_close_in')
  " Asynchronous Lint Engine
  Plug 'w0rp/ale'
else
  " Syntax checking plugin
  Plug 'vim-syntastic/syntastic'
endif

" Motions and text changing
" Autocomplete if end
Plug 'tpope/vim-endwise'
" The missing motion for Vim
Plug 'justinmk/vim-sneak'
" Provide CamelCase motion through words
Plug 'bkad/CamelCaseMotion'
" Extended % matching for HTML, LaTeX, and many other languages
Plug 'tmhedberg/matchit'
" Bullets.vim is a Vim/NeoVim plugin for automated bullet lists.
Plug 'dkarter/bullets.vim'
" Auto close (X)HTML tags
Plug 'alvan/vim-closetag', {
      \ 'for': ['html', 'javascript.jsx', 'php', 'xhtml', 'xml'] }
" Simplify the transition between multiline and single-line code
Plug 'AndrewRadev/splitjoin.vim'
" Easily delete, change and add surroundings in pairs
Plug 'tpope/vim-surround'
" Pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'
if v:version == 704 && !has('patch754') || v:version < 704 && v:version >= 700
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
" :substitute preview
Plug 'osyo-manga/vim-over'
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
Plug 'yous/adblock-filter.vim', { 'for': 'adblockfilter' }
" Aheui
Plug 'yous/aheui.vim', { 'for': 'aheui' }
" CUP
Plug 'gcollura/cup.vim', { 'for': 'cup' }
" GNU As
Plug 'Shirk/vim-gas', { 'for': 'gas' }
" LaTeX
Plug 'lervag/vimtex', { 'for': ['bib', 'tex'] }
" Markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' } |
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
" PHP
Plug 'vim-scripts/php.vim-html-enhanced', { 'for': ['html', 'php'] }
" Rails
Plug 'tpope/vim-rails'
if v:version >= 700
  " ANSI escape sequences concealed, but highlighted as specified (conceal)
  Plug 'powerman/vim-plugin-AnsiEsc', { 'for': 'railslog' }
endif
" Rake
Plug 'tpope/vim-rake'
" RuboCop
Plug 'ngmy/vim-rubocop', { 'on': 'RuboCop' }
" smali
Plug 'kelwin/vim-smali', { 'for': 'smali' }
" SMT-LIB
Plug 'raichoo/smt-vim', { 'for': 'smt' }
" Vader
Plug 'junegunn/vader.vim', { 'for': 'vader' }
" A solid language pack for Vim
Plug 'sheerun/vim-polyglot'

" macOS
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

" Automatically install missing plugins on startup
autocmd vimrc VimEnter *
      \ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) |
      \   PlugInstall --sync |
      \ endif

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
" Files with these suffixes get a lower priority when multiple files match a
" wildcard
set suffixes+=.git,.hg,.svn
set suffixes+=.bmp,.gif,.jpeg,.jpg,.png
set suffixes+=.dll,.exe
set suffixes+=.swo
set suffixes+=.DS_Store
set suffixes+=.pyc
" Maximum number of changes that can be undone
set undolevels=1000
" Update swap file and trigger CursorHold after 1 second
set updatetime=100
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
  if $COLORTERM ==# 'truecolor'
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
  if a:enabled && index(['GV', 'vim-plug'], &filetype) < 0
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
" Use the value of 'shiftwidth'
set softtabstop=-1
" Number of spaces to use for each setp of (auto)indent
set shiftwidth=2
" Number of spaces that a <Tab> in the file counts for
set tabstop=8
" Maximum width of text that is being inserted
set textwidth=80
autocmd vimrc FileType c,cpp,java,json,perl,python
      \ setlocal shiftwidth=4
autocmd vimrc FileType asm,gitconfig,kconfig
      \ setlocal noexpandtab shiftwidth=8
autocmd vimrc FileType make
      \ let &l:shiftwidth = &l:tabstop
autocmd vimrc FileType go
      \ setlocal noexpandtab shiftwidth=4 tabstop=4
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
      \ if index(['gitcommit',
      \           'gitsendemail',
      \           'markdown',
      \           'tex'], &filetype) < 0 |
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

" Use CTRL-N to clear the highlighting
nnoremap <silent> <C-N> :nohlsearch<C-R>=has('diff') ? '<Bar>diffupdate' : ''<CR><CR>

" Clear screen
nnoremap <Leader><C-L> <C-L>

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
  if exists('t:zoom_winrestcmd')
    execute t:zoom_winrestcmd
    if t:zoom_winrestcmd !=# winrestcmd()
      wincmd =
    endif
    unlet t:zoom_winrestcmd
  elseif tabpagewinnr(tabpagenr(), '$') > 1
    " Resize only when multiple windows are in the current tab page
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
  endif
endfunction
nnoremap <silent> <Leader>z :call <SID>ZoomToggle()<CR>

" Cscope mappings
if has('cscope') && executable('cscope')
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

function! s:RemapBufferQ()
  nnoremap <buffer> q :q<CR>
endfunction

augroup vimrc
  " Quit help, quickfix window
  autocmd FileType help,qf call s:RemapBufferQ()

  " Quit preview window
  autocmd BufEnter *
        \ if &previewwindow |
        \   call s:RemapBufferQ() |
        \ endif

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
function! s:CheckLeftBuffers(quitpre)
  if tabpagenr('$') == 1
    let l:i = 1
    while l:i <= winnr('$')
      if a:quitpre && l:i == winnr()
        let l:i += 1
        continue
      endif
      let l:filetypes = ['help', 'qf', 'nerdtree', 'taglist']
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
if exists('##QuitPre')
  autocmd vimrc QuitPre * call s:CheckLeftBuffers(1)
else
  autocmd vimrc BufEnter * call s:CheckLeftBuffers(0)
endif

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

  " Automatically update the diff after writing changes
  autocmd BufWritePost * if &diff | diffupdate | endif

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
  autocmd FileType GV,vim-plug
        \ setlocal colorcolumn= nolist textwidth=0

  " Ruby configuration files view
  autocmd BufNewFile,BufRead Gemfile,Guardfile setlocal filetype=ruby

  " ASM view
  autocmd BufNewFile,BufRead *.S setlocal filetype=gas

  " Gradle view
  autocmd BufNewFile,BufRead *.gradle setlocal filetype=groovy

  " LD script view
  autocmd BufNewFile,BufRead *.lds setlocal filetype=ld

  " Markdown view
  autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

  " mobile.erb view
  autocmd BufNewFile,BufRead *.mobile.erb
        \ let b:eruby_subtype = 'html' |
        \ setlocal filetype=eruby

  " zsh-theme view
  autocmd BufNewFile,BufRead *.zsh-theme setlocal filetype=zsh
augroup END

" Auto insert for git commit
let s:gitcommit_insert = 0
augroup gitcommit_insert
  autocmd!
  autocmd FileType gitcommit
        \ if byte2line(2) == 2 |
        \   let s:gitcommit_insert = 1 |
        \ endif
  autocmd VimEnter *
        \ if (s:gitcommit_insert) |
        \   startinsert |
        \ endif
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

" vim-sleuth
let g:sleuth_automatic = 1

" vim-gutentags
function! s:BuildTagsFileListCmd(prog)
  let l:filetypes = [
        \ 'asm', 'c', 'h', 'S',
        \ 'cpp', 'hpp',
        \ 'cc',
        \ 'go',
        \ 'java',
        \ 'js',
        \ 'py',
        \ 'rb']
  if a:prog ==# 'git'
    " git ls-files '*.c' '*.h'
    let l:cmd = 'git ls-files ' .
          \ join(map(l:filetypes, '"''*." . v:val . "''"'), ' ')
  elseif a:prog ==# 'hg'
    " hg files -I '**.c' -I '**.h'
    let l:cmd = 'hg files ' .
          \ join(map(l:filetypes, '"-I ''**." . v:val . "''"'), ' ')
  elseif a:prog ==# 'find'
    " find . -type f \( -name '*.c' -o -name '*.h' \)
    let l:cmd = 'find . -type f ' .
          \ '\( ' .
          \ join(map(l:filetypes, '"-name ''*." . v:val . "''"'), ' -o ') .
          \ ' \)'
  elseif a:prog ==# 'dir'
    " dir /S /B /A-D *.c *.h
    let l:cmd = 'dir /S /B /A-D ' .
          \ join(map(l:filetypes, '"*." . v:val'), ' ')
  endif

  return l:cmd
endfunction
let g:gutentags_modules = []
if executable('ctags')
  call add(g:gutentags_modules, 'ctags')
endif
if executable('cscope')
  call add(g:gutentags_modules, 'cscope')
endif
let g:gutentags_file_list_command = {
      \ 'markers': {
      \   '.git': s:BuildTagsFileListCmd('git'),
      \   '.hg': s:BuildTagsFileListCmd('hg')
      \ },
      \ 'default': has('win32')
      \   ? s:BuildTagsFileListCmd('dir')
      \   : s:BuildTagsFileListCmd('find') }

" fzf.vim
nnoremap <C-P> :Files<CR>
nnoremap g<C-P> :GFiles<CR>
nnoremap t<C-P> :Tags<CR>
nnoremap c<C-P> :History :<CR>
if executable('rg')
  command! -bang -nargs=* Rg
        \ call fzf#vim#grep('rg --column --line-number --no-heading ' .
        \   '--color=always --smart-case ' . shellescape(<q-args>),
        \   1, fzf#vim#with_preview('right:50%'), <bang>0)
  nnoremap <Leader>* :Rg<Space><C-R>=expand('<cword>')<CR><CR>
endif

" vim-dirvish
function! s:ResetDirvishCursor()
  let l:curline = getline('.')
  keepjumps call search('\V\^' . escape(l:curline, '\') . '\$', 'cw')
endfunction
augroup dirvish_config
  autocmd!
  autocmd FileType dirvish silent! unmap <buffer> <C-N>
  autocmd FileType dirvish silent! unmap <buffer> <C-P>
  autocmd FileType dirvish call <SID>ResetDirvishCursor()
augroup END

" YouCompleteMe
let g:ycm_min_num_of_chars_for_completion = 4
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
let g:ycm_show_diagnostics_ui = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_extra_conf_globlist = ['~/*']
let g:ycm_semantic_triggers = {
      \ 'c': ['re![_a-zA-Z]\w{3,}'],
      \ 'cpp': ['re![_a-zA-Z]\w{3,}'] }

" echodoc.vim
if has_key(g:plugs, 'echodoc.vim')
  set noshowmode
  set completeopt-=preview

  let g:echodoc#enable_at_startup = 1
endif

" ale
if has_key(g:plugs, 'ale')
  let g:ale_echo_msg_format = '[%linter%] %code: %%s'
  let g:ale_lint_on_save = 1
  let g:ale_lint_on_text_changed = 0
  let g:ale_linters = {
        \ 'rust': 'all' }
  let g:ale_set_highlights = 0
  let g:ale_statusline_format = ['%d error(s)', '%d warning(s)', '']

  " ale-cpp-clangcheck
  " ale-c-clangformat, ale-cpp-clangformat
  " ale-c-clangtidy, ale-cpp-clangtidy
  for [s:prog, s:slug, s:langs] in [
        \ ['clang-check', 'clangcheck', ['cpp']],
        \ ['clang-format', 'clangformat', ['c']],
        \ ['clang-tidy', 'clangtidy', ['c', 'cpp']]]
    let s:llvm_prog = '/usr/local/opt/llvm/bin/' . s:prog
    if !executable(s:prog) && executable(s:llvm_prog)
      for s:lang in s:langs
        let g:[printf('ale_%s_%s_executable', s:lang, s:slug)] = s:llvm_prog
      endfor
    endif
  endfor

  " See http://clang.llvm.org/extra/clang-tidy/.
  let g:ale_c_clangtidy_checks = [
        \ '*',
        \ '-fuchsia-*',
        \ '-google-readability-todo',
        \ '-hicpp-braces-around-statements',
        \ '-hicpp-signed-bitwise',
        \ '-llvm-*',
        \ '-readability-*']
  let g:ale_cpp_clangtidy_checks = [
        \ '*',
        \ '-fuchsia-*',
        \ '-google-readability-todo',
        \ '-hicpp-braces-around-statements',
        \ '-hicpp-signed-bitwise',
        \ '-llvm-*',
        \ '-readability-*']
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

" vim-sneak
let g:sneak#s_next = 1
map f <Plug>Sneak_s
map F <Plug>Sneak_S

" CamelCaseMotion
function! s:CreateCamelCaseMotionMappings()
  for l:mode in ['n', 'o', 'x']
    for l:motion in ['w', 'b', 'e']
      let l:target_mapping = '<Plug>CamelCaseMotion_' . l:motion
      execute l:mode . 'map <silent> <Leader>' . l:motion . ' '
            \ . l:target_mapping
    endfor
  endfor
endfunction
call s:CreateCamelCaseMotionMappings()

" bullets.vim
let g:bullets_enabled_file_types = [
      \ 'gitcommit',
      \ 'gitsendemail',
      \ 'markdown',
      \ 'text']

" vim-closetag
let g:closetag_filetypes = 'html,javascript.jsx,php,xhtml,xml'
let g:closetag_xhtml_filetypes = 'javascript.jsx,xhtml,xml'

" vim-unimpaired
" Center display on move
function! s:RemapUnimpairedToCenter()
  for [l:key, l:cmd] in [
        \ ['l', 'L'],
        \ ['q', 'Q'],
        \ ['t', 'T'],
        \ ['n', 'Context']]
    let l:plug_map = '<Plug>unimpaired' . l:cmd
    execute 'nmap [' . l:key . ' ' . l:plug_map . 'Previous' . 'zz'
    execute 'nmap ]' . l:key . ' ' . l:plug_map . 'Next' . 'zz'
  endfor
endfunction
call s:RemapUnimpairedToCenter()

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
      \   'ale': 'LightLineALEStatusline',
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
  let l:fpath = expand('%')
  return &filetype ==# 'dirvish' ?
        \   (l:fpath ==# getcwd() . '/' ? fnamemodify(l:fpath, ':~') :
        \   fnamemodify(l:fpath, ':~:.')) :
        \ l:fname ==# '__Tag_List__' ? '' :
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

  function! LightLineALEStatusline()
    let l:counts = ale#statusline#Count(bufnr('%'))
    let l:errors = l:counts.error + l:counts.style_error
    let l:warnings = l:counts.total - l:errors
    let l:error_msg = l:errors ? printf('%d error(s)', l:errors) : ''
    let l:warning_msg = l:warnings ? printf('%d warning(s)', l:warnings) : ''

    if l:errors && l:warnings
      return printf('%s %s', l:error_msg, l:warning_msg)
    else
      return l:errors ? l:error_msg : (l:warnings ? l:warning_msg : '')
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

" vim-gitgutter
function! s:RedefineGitGutterAutocmd()
  if get(g:, 'gitgutter_async', 0) && gitgutter#async#available()
    autocmd! gitgutter CursorHold,CursorHoldI
    autocmd gitgutter CursorHold,CursorHoldI *
          \ call gitgutter#process_buffer(bufnr(''), 1)
  endif
endfunction
autocmd vimrc VimEnter * call s:RedefineGitGutterAutocmd()

" goyo.vim
nnoremap <Leader>G :Goyo<CR>

" adblock-filter.vim
let g:adblock_filter_auto_checksum = 1

" vimtex
if has('win32unix')
  let g:vimtex_compiler_enabled = 0
  let g:vimtex_complete_enabled = 0
  let g:vimtex_view_enabled = 0
endif
if !has('clientserver') && !has('nvim')
  let g:vimtex_compiler_latexmk = {
        \ 'callback': 0 }
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

" vim-plugin-AnsiEsc
autocmd vimrc FileType railslog :AnsiEsc

" vim-rake
nnoremap <Leader>ra :Rake<CR>

" vim-rubocop
let g:vimrubocop_extra_args = '--display-cop-names'
let g:vimrubocop_keymap = 0
nnoremap <Leader>ru :RuboCop<CR>

" vim-polyglot
let g:polyglot_disabled = ['latex', 'markdown']
" vim-javascript
let g:javascript_plugin_jsdoc = 1

" macOS
if has('mac') || has('macunix')
  " vim-plist
  function! s:ConvertBinaryPlist()
    silent! execute '%d'
    call plist#Read(1)
    call plist#ReadPost()
    set fileencoding=utf-8

    autocmd! vimrc BufWriteCmd,FileWriteCmd <buffer>
    autocmd vimrc BufWriteCmd,FileWriteCmd <buffer>
          \ call plist#Write()
  endfunction
  autocmd vimrc BufRead *
        \ if getline(1) =~# '^bplist' |
        \   call s:ConvertBinaryPlist() |
        \ endif
  autocmd vimrc BufNewFile *.plist
        \ if !get(b:, 'plist_original_format') |
        \   let b:plist_original_format = 'xml' |
        \ endif

  " dash.vim
  let g:dash_map = {
        \ 'java': 'android' }
  nnoremap <Leader>d <Plug>DashSearch
endif

" }}}
" =============================================================================
