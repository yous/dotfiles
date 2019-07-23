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

if !has('nvim')
  let s:python3_neovim = 0
  let s:python2_neovim = 0

  if has('python3')
    if !has('patch-8.1.201')
      silent! python3 1
    endif

    try
      python3 import pynvim
      let s:python3_neovim = 1
    catch /^Vim(python3):/
    endtry
  endif

  if has('python')
    try
      python import pynvim
      let s:python2_neovim = 1
    catch /^Vim(python):/
    endtry
  endif
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
" EditorConfig plugin for Vim
Plug 'editorconfig/editorconfig-vim'
" sleuth.vim: Heuristically set buffer options
Plug 'tpope/vim-sleuth'
" A Plugin to show a diff, whenever recovering a buffer
Plug 'chrisbra/Recover.vim'
" obsession.vim: continuously updated session files
Plug 'tpope/vim-obsession'
" Vim plugin to edit binary files in a hex mode automatically
Plug 'fidian/hexmode'
" Vim sugar for the UNIX shell commands
Plug 'tpope/vim-eunuch'
" Vim plugin to diff two directories
Plug 'will133/vim-dirdiff'
" Vim: file and hunk folding support for diff/patch files.
Plug 'sgeb/vim-diff-fold'
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
" Dark powered asynchronous completion framework for neovim/Vim8
if has('nvim-0.3.1') || v:version >= 800
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
endif
" Print documents in echo area
if exists('v:completed_item') && exists('v:event')
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
" The set of operator and textobject plugins to search/select/edit sandwiched
" textobjects
Plug 'machakann/vim-sandwich'
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
" Highlight the exact differences, based on characters and words
Plug 'rickhowe/diffchar.vim'
if has('patch-8.0.1206') || has('nvim-0.2.3')
  " Range, pattern and substitute preview for Vim
  Plug 'markonm/traces.vim'
elseif v:version >= 703
  " :substitute preview
  Plug 'osyo-manga/vim-over'
endif
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
" color hex codes and color names
Plug 'chrisbra/Colorizer'

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
augroup VimPlug
  autocmd!
  autocmd VimEnter *
        \ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) |
        \   PlugInstall --sync |
        \ endif
augroup END

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
" How keyword completion works when CTRL-P and CTRL-N are used
" i: scan current and included files
set complete-=i
if has('patch-8.1.0360')
  set diffopt+=algorithm:patience
endif
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
  set listchars=tab:→\ ,trail:·,extends:»,precedes:«,nbsp:~
catch /^Vim\%((\a\+)\)\=:E474/
  set listchars=tab:>\ ,trail:_,extends:>,precedes:<,nbsp:~
endtry
" The key sequence that toggles the 'paste' option
set pastetoggle=<F2>
if has('mksession')
  " Changes the effect of the :mksession command
  set sessionoptions-=buffers " hidden and unloaded buffers
endif
" Help to avoid all the hit-enter prompts caused by file messages and to avoid
" some other messages
" m: use "[+]" instead of "[Modified]"
" r: use "[RO]" instead of "[readonly]"
" c: don't give ins-completion-menu messages
set shortmess+=m
set shortmess+=r
set shortmess+=c
" Exclude East Asian characters from spell checking
set spelllang+=cjk
" Files with these suffixes get a lower priority when multiple files match a
" wildcard
set suffixes+=.git,.hg,.svn
set suffixes+=.bmp,.gif,.jpeg,.jpg,.png
set suffixes+=.dll,.exe
set suffixes+=.swo
set suffixes+=.DS_Store
set suffixes+=.pyc
" Filenames for the tag command, separated by spaces or commas
if has('path_extra')
  set tags-=./tags
  set tags-=./tags;
  set tags^=./tags;
endif
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

" Rust
if executable('rustfmt')
  let g:rustfmt_autosave = 1
endif

" TeX
let g:tex_conceal = 'abdmg'
let g:tex_flavor = 'latex'

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
if empty($STY) && get(g:, 'colors_name', 'default') !=# 'default'
  " See https://gist.github.com/XVilka/8346728.
  if $COLORTERM =~# 'truecolor' || $COLORTERM =~# '24bit'
    if has('termguicolors')
      " :help xterm-true-color
      if $TERM =~# '^screen'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      endif
      set termguicolors
    endif
  endif
endif

augroup ColorColumn
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
highlight link ExtraWhitespace Error
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
  set guioptions+=! " External commands are executed in a terminal window
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
" Number of spaces to use for each step of (auto)indent
set shiftwidth=2
" <Tab> in front of a line inserts blanks according to 'shiftwidth'
set smarttab
" Number of spaces that a <Tab> in the file counts for
set tabstop=8
" Maximum width of text that is being inserted
set textwidth=80
augroup TextFormatting
  autocmd!

  autocmd FileType asm,gitconfig,kconfig
        \ setlocal noexpandtab shiftwidth=8

  " Show utf-8 glyphs for TeX
  autocmd FileType bib,tex setlocal conceallevel=1

  autocmd FileType c,cpp,java,json,perl
        \ setlocal shiftwidth=4

  autocmd FileType go
        \ setlocal noexpandtab shiftwidth=4 tabstop=4

  " Plain view for plugins
  autocmd FileType GV,vim-plug
        \ setlocal colorcolumn= nolist textwidth=0

  autocmd FileType make
        \ let &l:shiftwidth = &l:tabstop

  autocmd FileType python
        \ setlocal shiftwidth=4 textwidth=79

  " t: Auto-wrap text using textwidth
  " c: Auto-wrap comments using textwidth
  " r: Automatically insert the current comment leader after hitting <Enter> in
  "    Insert mode
  " o: Automatically insert the current comment leader after hitting 'o' or 'O'
  "    in Normal mode
  " q: Allow formatting of comments with "gq"
  " l: Long lines are not broken in insert mode
  " j: Remove a comment leader when joining lines
  autocmd FileType *
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
augroup END

" }}}
" =============================================================================
" Mappings: {{{
" =============================================================================

" Commander
nnoremap ; :

" We do line wrap
for s:mode in ['n', 'o']
  for s:key in ['j', 'k']
    execute s:mode . 'noremap ' . s:key . ' g' . s:key
    execute s:mode . 'noremap g' . s:key . ' ' . s:key
  endfor
endfor
nnoremap <Down> gj
nnoremap <Up> gk
onoremap <Down> gj
onoremap <Up> gk

" Easy navigation on a line
noremap H ^
noremap L $

" Unix shell behavior
inoremap <C-A> <C-C>I
inoremap <expr> <C-E> pumvisible() ? "\<C-E>" : "\<End>"

" Close braces
function! s:CloseBrace()
  let l:line_num = line('.')
  let l:next_line = getline(l:line_num + 1)
  if !empty(l:next_line) &&
        \ indent(l:line_num + 1) == indent(l:line_num) &&
        \ l:next_line =~# '^\s*}'
    return "{\<CR>"
  elseif (&filetype ==# 'c' || &filetype ==# 'cpp') &&
        \ getline(l:line_num) =~# '^\s*\%(typedef\s*\)\?\%(struct\|enum\)\s\+'
    return "{\<CR>};\<C-C>O"
  else
    return "{\<CR>}\<C-C>O"
  endif
endfunction
inoremap <expr> {<CR> <SID>CloseBrace()

" Navigate completions
inoremap <expr> <Tab> pumvisible() ? "\<C-N>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"

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
nnoremap <silent> <C-N> :<C-U>nohlsearch<C-R>=has('diff') ? '<Bar>diffupdate' : ''<CR><CR>

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
vnoremap * :<C-U>call <SID>VSearch('/')<CR>/<C-R>/<CR>zz
vnoremap # :<C-U>call <SID>VSearch('?')<CR>?<C-R>/<CR>zz

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
nnoremap <silent> <Leader>z :<C-U>call <SID>ZoomToggle()<CR>

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

function! s:MapSaveAndRun(key, cmd)
  if a:cmd =~# '^make'
    let l:pre_make = 'let &l:cmdheight += 1<Bar>'
    let l:post_make = '<Bar>let &l:cmdheight -= 1'
  else
    let l:pre_make = ''
    let l:post_make = ''
  endif
  execute 'nnoremap <buffer> ' . a:key .
        \ ' :<C-U>w<CR>:' . l:pre_make . a:cmd . l:post_make . '<CR>'
  execute 'inoremap <buffer> ' . a:key .
        \ ' <Esc>:w<CR>:' . l:pre_make . a:cmd . l:post_make . '<CR>'
endfunction

function! s:MapCompilingRust()
  if strlen(findfile('Cargo.toml', '.;')) > 0
    " CompilerSet makeprg=cargo\ $*
    call s:MapSaveAndRun('<F5>', 'make build')
    call s:MapSaveAndRun('<F6>', 'make run')
  else
    " CompilerSet makeprg=rustc\ \%
    call s:MapSaveAndRun('<F5>', 'make -o %<')
  endif
endfunction

augroup FileTypeMappings
  autocmd!

  " Quit help, quickfix window
  autocmd FileType help,qf call s:RemapBufferQ()

  " Quit preview window
  autocmd BufEnter *
        \ if &previewwindow |
        \   call s:RemapBufferQ() |
        \ endif

  " C, C++ compile
  autocmd FileType c,cpp call s:MapSaveAndRun('<F5>', 'make')
  autocmd FileType c
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   setlocal makeprg=gcc\ -o\ %<\ % |
        \ endif
  autocmd FileType cpp
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   setlocal makeprg=g++\ -o\ %<\ % |
        \ endif

  " Markdown code snippets
  autocmd FileType markdown inoremap <buffer> <LocalLeader>` ```

  " Go
  autocmd FileType go call s:MapSaveAndRun('<F5>', '!go run %')

  " Python
  autocmd FileType python call s:MapSaveAndRun('<F5>', '!python %')

  " Ruby
  autocmd FileType ruby call s:MapSaveAndRun('<F5>', '!ruby %')

  " Rust
  autocmd FileType rust call s:MapCompilingRust()
augroup END

" File execution
if has('win32')
  nnoremap <F6> :<C-U>!%<.exe<CR>
  inoremap <F6> <Esc>:!%<.exe<CR>
elseif has('unix')
  nnoremap <F6> :<C-U>!./%<<CR>
  inoremap <F6> <Esc>:!./%<<CR>
endif

" }}}
" =============================================================================
" Commands: {{{
" =============================================================================

" :Gdiffs
if has('win32')
  command! Gdiffs cexpr system('git diff \| diff-hunk-list.bat') |
        \ cwindow | wincmd p
else
  command! Gdiffs cexpr system('git diff \| diff-hunk-list') |
        \ cwindow | wincmd p
endif

" :Syn
" https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
command! Syn :echo 'hi<' . synIDattr(synID(line('.'), col('.'), 1), 'name') .
      \ '> trans<' . synIDattr(synID(line('.'), col('.'), 0), 'name') .
      \ '> lo<' . synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name') .
      \ '>'

" }}}
" =============================================================================
" Autocmd: {{{
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
augroup AutoQuit
  autocmd!
  if exists('##QuitPre')
    autocmd QuitPre * call s:CheckLeftBuffers(1)
  else
    autocmd BufEnter * call s:CheckLeftBuffers(0)
  endif
augroup END

augroup AutoUpdates
  autocmd!

  " Automatically update the diff after writing changes
  autocmd BufWritePost * if &diff | diffupdate | endif

  " Exit Paste mode when leaving Insert mode
  autocmd InsertLeave * if &paste | set nopaste | endif

  " Check if any buffers were changed outside of Vim
  autocmd FocusGained,BufEnter * checktime
augroup END

augroup FileTypeAutocmds
  autocmd!

  " Keyword lookup program
  autocmd FileType c,cpp setlocal keywordprg=man
  autocmd FileType gitconfig
        \ setlocal keywordprg=man\ git-config\ \|\ less\ -i\ -p
  autocmd FileType help,vim setlocal keywordprg=:help
  autocmd FileType ruby setlocal keywordprg=ri

  " Terminal
  if has('nvim')
    autocmd TermOpen * setlocal nonumber | startinsert
  endif

  " ASM view
  autocmd BufNewFile,BufRead *.S setlocal filetype=gas

  " Gradle view
  autocmd BufNewFile,BufRead *.gradle setlocal filetype=groovy

  " LD script view
  autocmd BufNewFile,BufRead *.lds setlocal filetype=ld

  " mobile.erb view
  autocmd BufNewFile,BufRead *.mobile.erb
        \ let b:eruby_subtype = 'html' |
        \ setlocal filetype=eruby

  " zsh-theme view
  autocmd BufNewFile,BufRead *.zsh-theme setlocal filetype=zsh
augroup END

" Disable swapfile for Dropbox
augroup DisableSwap
  autocmd!
  autocmd BufNewFile,BufRead *
        \ if expand('%:p:~') =~# '/Dropbox/' |
        \   setlocal noswapfile |
        \ endif
augroup END

" Auto insert for git commit
let s:gitcommit_insert = 0
augroup GitcommitInsert
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

augroup LoadVimrc
  autocmd!
  " Reload vimrc on the fly
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

" Reload symlink of vimrc on the fly
let s:resolved_vimrc = resolve(expand($MYVIMRC))
if expand($MYVIMRC) !=# s:resolved_vimrc
  execute 'autocmd LoadVimrc BufWritePost ' . s:resolved_vimrc .
        \ ' nested source $MYVIMRC'
endif

" }}}
" =============================================================================
" Plugins: {{{
" =============================================================================

" PreserveNoEOL
let g:PreserveNoEOL = 1

" vim-sleuth
let g:sleuth_automatic = 1

" vim-obsession
if has_key(g:plugs, 'tcd.vim')
  function! s:SaveTabInfo()
    if !exists('g:this_session')
      return
    endif

    let l:lines = []
    for l:tabnr in range(1, tabpagenr('$'))
      let l:tabvars = gettabvar(l:tabnr, '')
      for l:var in [
            \ 'tcd_ocwd', 'tcd_cwd'] " tcd.vim
        if has_key(l:tabvars, l:var)
          let l:val = l:tabvars[l:var]
          let l:lines += ['call settabvar(' .
                \ l:tabnr . ', ' .
                \ "'" . l:var . "', " .
                \ "'" . substitute(l:val, "'", "''", 'g') . "')"]
        endif
      endfor
    endfor

    if empty(l:lines)
      return
    endif

    let l:body = readfile(g:this_session)
    for l:line in l:lines
      call insert(l:body, l:line, -3)
    endfor
    call writefile(l:body, g:this_session)
  endfunction
  augroup ObsessionSaveTabInfo
    autocmd!
    autocmd User Obsession call s:SaveTabInfo()
  augroup END
endif

" hexmode
let g:hexmode_xxd_options = '-g 4'

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
let g:gutentags_cscope_build_inverted_index = 1

" fzf.vim
if has_key(g:plugs, 'fzf.vim')
  nnoremap <C-P> :Files<CR>
  nnoremap g<C-P> :GFiles<CR>
  nnoremap t<C-P> :Tags<CR>
  nnoremap c<C-P> :History :<CR>
  if executable('rg')
    function! s:GetVisualSelection()
      let [l:line_start, l:column_start] = getpos("'<")[1:2]
      let [l:line_end, l:column_end] = getpos("'>")[1:2]
      let l:lines = getline(l:line_start, l:line_end)
      if len(l:lines) == 0
        return ''
      endif
      let l:offset = &selection ==# 'exclusive' ? 2 : 1
      let l:lines[-1] = l:lines[-1][:l:column_end - l:offset]
      let l:lines[0] = l:lines[0][l:column_start - 1:]
      return join(l:lines, "\n")
    endfunction
    command! -bang -nargs=* Rg
          \ call fzf#vim#grep('rg --column --line-number --no-heading ' .
          \   '--color=always --smart-case --fixed-strings ' .
          \   shellescape(<q-args>),
          \   1, fzf#vim#with_preview('right:50%'), <bang>0)
    command! -bang -nargs=* Rgr
          \ call fzf#vim#grep('rg --column --line-number --no-heading ' .
          \   '--color=always --smart-case ' . shellescape(<q-args>),
          \   1, fzf#vim#with_preview('right:50%'), <bang>0)
    nnoremap <Leader>* :<C-U>Rg<Space><C-R>=expand('<cword>')<CR><CR>
    vnoremap <Leader>* :<C-U>Rg<Space><C-R>=<SID>GetVisualSelection()<CR><CR>
  endif
  if has('nvim')
    augroup FZFStatusline
      autocmd!
      autocmd FileType fzf
            \ let s:laststatus = &laststatus | set laststatus=0 |
            \ let s:showmode = &showmode | set noshowmode |
            \ let s:ruler = &ruler | set noruler |
            \ autocmd BufLeave <buffer>
            \   let &laststatus = s:laststatus | unlet s:laststatus |
            \   let &showmode = s:showmode | unlet s:showmode |
            \   let &ruler = s:ruler | unlet s:ruler
    augroup END
  endif
endif

" vim-dirvish
function! s:ResetDirvishCursor()
  let l:curline = getline('.')
  keepjumps call search('\V\^' . escape(l:curline, '\') . '\$', 'cw')
endfunction
augroup DirvishConfig
  autocmd!
  autocmd FileType dirvish silent! unmap <buffer> <C-N>
  autocmd FileType dirvish silent! unmap <buffer> <C-P>
  autocmd FileType dirvish call <SID>ResetDirvishCursor()
augroup END

" coc.nvim
if has_key(g:plugs, 'coc.nvim')
  function! s:GenerateCclsConfig()
    let l:ccls_config = {
          \ 'command': 'ccls',
          \ 'filetypes': ['c', 'cpp', 'cuda', 'objc', 'objcpp'],
          \ 'rootPatterns': [
          \   '.ccls', 'compile_commands.json', '.vim/', '.git/', '.hg/'],
          \ 'initializationOptions': {
          \   'cache': {
          \     'directory': $HOME . '/.ccls-cache'
          \   }
          \ } }
    if has('mac') || has('macunix')
      let l:ccls_config['initializationOptions']['clang'] = {
            \ 'extraArgs': [
            \   '-isystem',
            \   '/Applications/Xcode.app/Contents/Developer/Toolchains/' .
            \     'XcodeDefault.xctoolchain/usr/include/c++/v1',
            \   '-I',
            \   '/Applications/Xcode.app/Contents/Developer/Platforms/' .
            \     'MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/'] }
      let l:clang_dirs = systemlist(
            \ 'find /Library/Developer/CommandLineTools/usr/lib/clang ' .
            \   '-depth 1 2>/dev/null')
      if !empty(l:clang_dirs) && !empty(l:clang_dirs[0])
        let l:ccls_config['initializationOptions']['clang']['resourceDir'] =
              \ l:clang_dirs[0]
      endif
    endif
    return l:ccls_config
  endfunction

  let g:coc_global_extensions = [
        \ 'coc-css',
        \ 'coc-emoji',
        \ 'coc-json',
        \ 'coc-python',
        \ 'coc-tag',
        \ 'coc-tsserver']
  if executable('ccls')
    call coc#config('languageserver', { 'ccls': s:GenerateCclsConfig() })
  endif

  augroup CocFileType
    autocmd!
    autocmd FileType diff,mail,markdown,netrw,qf,tagbar,text
          \ let b:coc_enabled = 0
  augroup END
endif

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

  " ale-c-options, ale-cpp-options
  let g:ale_c_parse_compile_commands = 1

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

  " ale-c-ccls, ale-cpp-ccls
  let g:ale_c_ccls_init_options = {
        \ 'cache': {
        \   'directory': $HOME . '/.ccls-cache'
        \ } }
  let g:ale_cpp_ccls_init_options = {
        \ 'cache': {
        \   'directory': $HOME . '/.ccls-cache'
        \ } }

  " ale-python-mypy
  if has('win32')
    let g:ale_python_mypy_options = '--cache-dir=nul'
  else
    let g:ale_python_mypy_options = '--cache-dir=/dev/null'
  endif
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
  let g:syntastic_stl_format = '%E{E(%e)}%B{ }%W{W(%w)}'
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
let g:nremap = {}
" Center display on move
function! s:RemapUnimpairedToCenter()
  for [l:key, l:cmd] in [
        \ ['l', 'L'],
        \ ['q', 'Q'],
        \ ['t', 'T'],
        \ ['n', 'Context']]
    let l:plug_map = '\<Plug>unimpaired' . l:cmd
    execute 'nnoremap <silent> [' . l:key .
          \ ' :<C-U>execute "normal " . v:count1 . "' .
          \ l:plug_map . 'Previous"<CR>zz'
    execute 'nnoremap <silent> ]' . l:key .
          \ ' :<C-U>execute "normal " . v:count1 . "' .
          \ l:plug_map . 'Next"<CR>zz'
    let g:nremap['[' . l:key] = ''
    let g:nremap[']' . l:key] = ''
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
      \     ['fugitive', 'filetype', 'fileencoding', 'fileformat']] },
      \ 'tabline': { 'left': [['tabs']], 'right': [[]] },
      \ 'tab': {
      \   'active': ['tabfilename', 'tabmodified'],
      \   'inactive': ['tabfilename', 'tabmodified'] },
      \ 'component': {
      \   'filename': '%<%{LightLineFilename()}' },
      \ 'component_function': {},
      \ 'tab_component_function': {},
      \ 'component_expand': {
      \   'readonly': 'LightLineReadonly',
      \   'eol': 'LightLineEol',
      \   'fugitive': 'LightLineFugitiveStatusline',
      \   'ale': 'LightLineALEStatusline',
      \   'syntastic': 'SyntasticStatuslineFlag' },
      \ 'component_type': {
      \   'readonly': 'warning',
      \   'eol': 'warning',
      \   'ale': 'error',
      \   'syntastic': 'error' },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '|' } }

for s:k in ['mode', 'modified', 'filetype', 'fileencoding',
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
        \ 'mode': 70,
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
        \ &filetype ==# 'fzf' ? 'fzf' :
        \ l:fname ==# '__Tag_List__' ? '' :
        \ l:fname ==# 'ControlP' ? '' :
        \ l:fname =~# 'NERD_tree' ?
        \   (index(['" Press ? for help', '.. (up a dir)'], getline('.')) < 0 ?
        \     matchstr(getline('.'), '[0-9A-Za-z_/].*') : '') :
        \ '' !=# l:fname ? fnamemodify(l:fpath, ':~:.') : '[No Name]'
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

function! LightLineFugitiveStatusline()
  if @% !~# '^fugitive:'
    return ''
  endif
  let l:head = FugitiveHead()
  if !len(l:head)
    return ''
  endif
  let l:commit = matchstr(FugitiveParse()[0], '^\x\+')
  if len(l:commit)
    return l:head . ':' . l:commit[0:6]
  else
    return l:head
  endif
endfunction

if has_key(g:plugs, 'ale')
  augroup LightLineALE
    autocmd!
    autocmd User ALELintPost,ALEFixPost call s:LightLineALE()
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
    let l:error_msg = l:errors ? printf('E(%d)', l:errors) : ''
    let l:warning_msg = l:warnings ? printf('W(%d)', l:warnings) : ''

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

" vim-over
if has_key(g:plugs, 'vim-over')
  let g:over#command_line#substitute#replace_pattern_visually = 1
  nnoremap :%s/ :OverCommandLine<CR>%s/
  vnoremap :s/ :OverCommandLine<CR>s/
endif

" rainbow_parentheses.vim
augroup RainbowParenthesesFileType
  autocmd!
  autocmd FileType clojure,lisp,racket,scheme RainbowParentheses
augroup END

" vim-gitgutter
function! s:RedefineGitGutterAutocmd()
  if get(g:, 'gitgutter_async', 0) && gitgutter#async#available()
    augroup gitgutter
      autocmd! CursorHold,CursorHoldI
      autocmd CursorHold,CursorHoldI *
            \ call gitgutter#process_buffer(bufnr(''), 1)
    augroup END
  endif
endfunction
augroup GitGutterConfig
  autocmd!
  autocmd VimEnter * call s:RedefineGitGutterAutocmd()
augroup END
nmap <Leader>ha <Plug>GitGutterStageHunk
nmap <Leader>hr <Plug>GitGutterUndoHunk
nmap <Leader>hv <Plug>GitGutterPreviewHunk

" goyo.vim
nnoremap <Leader>G :Goyo<CR>

" Colorizer
let g:colorizer_colornames = 0
let g:colorizer_disable_bufleave = 1

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
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_emphasis_multiline = 0
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
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
nnoremap <Plug> <Plug>Markdown_EditUrlUnderCursor
vnoremap <Plug> <Plug>Markdown_EditUrlUnderCursor
nnoremap <Plug> <Plug>Markdown_MoveToCurHeader
vnoremap <Plug> <Plug>Markdown_MoveToCurHeader

" vim-plugin-AnsiEsc
augroup AnsiEscFileType
  autocmd!
  autocmd FileType railslog :AnsiEsc
augroup END

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

    augroup BinaryPlistWrite
      autocmd! BufWriteCmd,FileWriteCmd <buffer>
      autocmd BufWriteCmd,FileWriteCmd <buffer> call plist#Write()
    augroup END
  endfunction
  augroup BinaryPlistRead
    autocmd!
    autocmd BufRead *
          \ if getline(1) =~# '^bplist' |
          \   call s:ConvertBinaryPlist() |
          \ endif
    autocmd BufNewFile *.plist
          \ if !get(b:, 'plist_original_format') |
          \   let b:plist_original_format = 'xml' |
          \ endif
  augroup END
  " Disable default autocmds
  let g:loaded_plist = 1
  let g:plist_display_format = 'xml'
  let g:plist_save_format = ''
  let g:plist_json_filetype = 'json'

  " dash.vim
  let g:dash_map = {
        \ 'java': 'android' }
  nmap <Leader>d <Plug>DashSearch
endif

" }}}
" =============================================================================
