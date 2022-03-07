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
  for idx in range(0, len(a:min) - 1)
    let v = get(a:val, idx, 0)
    if v < a:min[idx]
      return 0
    elseif v > a:min[idx]
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

filetype off

" Install vim-plug if it isn't installed
function! s:DownloadVimPlug()
  if !exists('s:vimfiles')
    return
  endif
  if empty(glob(s:vimfiles . '/autoload/plug.vim'))
    let plug_url = 'https://github.com/junegunn/vim-plug.git'
    let tmp = tempname()
    let new = tmp . '/plug.vim'

    try
      let out = system(printf('git clone --depth 1 %s %s', plug_url, tmp))
      if v:shell_error
        echohl ErrorMsg
        echomsg 'Error downloading vim-plug: ' . out
        echohl NONE
        return
      endif

      if !isdirectory(s:vimfiles . '/autoload')
        call mkdir(s:vimfiles . '/autoload', 'p')
      endif
      call rename(new, s:vimfiles . '/autoload/plug.vim')
    finally
      if isdirectory(tmp)
        let dir = '"' . escape(tmp, '"') . '"'
        silent call system((has('win32') ? 'rmdir /S /Q ' : 'rm -rf ') . dir)
      endif
    endtry
  endif
endfunction

" Install missing plugins
function! s:InstallMissingPlugins()
  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) |
    PlugInstall --sync
  endif
endfunction

call s:DownloadVimPlug()
call plug#begin(s:vimfiles . '/plugged')

" Colorscheme
Plug 'yous/vim-open-color'

" General
if !exists('+fixendofline')
  " Preserve missing EOL at the end of text files
  Plug 'yous/PreserveNoEOL', {
        \ 'commit': '9ef2f01',
        \ 'frozen': 1 }
endif
" EditorConfig plugin for Vim
Plug 'editorconfig/editorconfig-vim'
" A Plugin to show a diff, whenever recovering a buffer
Plug 'chrisbra/Recover.vim'
" obsession.vim: continuously updated session files
Plug 'tpope/vim-obsession'
if has('timers') && exists('v:exiting')
  " Fix CursorHold Performance
  Plug 'antoinemadec/FixCursorHold.nvim'
endif
" Ultimate hex editing system with Vim
Plug 'Shougo/vinarise.vim'
" Vim sugar for the UNIX shell commands
Plug 'tpope/vim-eunuch'
" the missing window movement
if exists('*win_screenpos') || exists('nvim_win_get_position')
  Plug 'andymass/vim-tradewinds'
endif
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
if !has('win32')
  " Git support for dirvish.vim
  Plug 'kristijanhusak/vim-dirvish-git'
endif
if !has('nvim') && !has('patch-8.1.1218')
  " Tab-specific directories
  Plug 'vim-scripts/tcd.vim'
endif
" Go to Terminal or File manager
Plug 'justinmk/vim-gtfo'

" Completion and lint
" Intellisense engine for Vim8 & Neovim, full language server protocol support
" as VSCode
if (has('nvim-0.3.2') || !has('nvim') && has('patch-8.0.1453')) &&
      \ executable('node')
  Plug 'neoclide/coc.nvim', { 'branch': 'release' }
endif
" Print documents in echo area
if exists('v:completed_item') && exists('v:event')
  Plug 'Shougo/echodoc.vim'
endif
if has('nvim') && has('timers') ||
      \ has('timers') && exists('*job_start') && exists('*ch_close_in')
  " Asynchronous Lint Engine
  Plug 'dense-analysis/ale'
else
  " Syntax checking plugin
  Plug 'vim-syntastic/syntastic'
endif

" Motions and text changing
" Autocomplete if end
Plug 'tpope/vim-endwise'
" Lightning fast left-right movement in Vim
Plug 'unblevable/quick-scope'
" More useful word motions for Vim
Plug 'chaoren/vim-wordmotion'
" The matchit plugin from Vim
Plug 'chrisbra/matchit'
" Python matchit support
Plug 'voithos/vim-python-matchit', { 'for': 'python' }
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
if !has('patch-8.1.1270') && !has('nvim-0.4.0')
  " vim-searchindex: display number of search matches & index of a current match
  Plug 'google/vim-searchindex'
endif
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
if has('patch-8.0.902') || has('nvim')
  " Show a diff using Vim its sign column.
  Plug 'mhinz/vim-signify'
elseif has('signs')
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
" GNU As
Plug 'Shirk/vim-gas', { 'for': 'gas' }
" LaTeX
Plug 'lervag/vimtex', { 'for': ['bib', 'tex'] }
" Markdown
Plug 'godlygeek/tabular', { 'for': 'markdown' } |
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
" PHP
Plug 'vim-scripts/php.vim-html-enhanced', { 'for': ['html', 'php'] }
if v:version >= 700
  " ANSI escape sequences concealed, but highlighted as specified (conceal)
  Plug 'powerman/vim-plugin-AnsiEsc', { 'for': 'railslog' }
endif
" Rake
Plug 'tpope/vim-rake'
" RBS
Plug 'pocke/rbs.vim'
" RuboCop
Plug 'ngmy/vim-rubocop', { 'on': 'RuboCop' }
" smali
Plug 'kelwin/vim-smali', { 'for': 'smali' }
" SMT-LIB
Plug 'raichoo/smt-vim', { 'for': 'smt' }
" Vader
Plug 'junegunn/vader.vim', { 'for': 'vader' }
" A solid language pack for Vim
let g:polyglot_disabled = [
      \ 'latex', 'markdown',
      \ 'autoindent', 'sensible']
Plug 'sheerun/vim-polyglot'

" macOS
if has('mac') || has('macunix')
  " Add plist editing support to Vim
  Plug 'darfink/vim-plist'
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
if has('unnamedplus')
  " Use X11 CLIPBOARD selection
  set clipboard=unnamedplus
endif
" How keyword completion works when CTRL-P and CTRL-N are used
" i: scan current and included files
set complete-=i
if has('mac') && $VIM ==# '/usr/share/vim'
  set diffopt-=internal
elseif has('patch-8.1.0360')
  set diffopt+=algorithm:patience
endif
if !isdirectory(s:vimfiles . '/swap')
  call mkdir(s:vimfiles . '/swap', 'p')
endif
" List of directory names for the swap file, separated with commas
execute 'set directory^=' . s:vimfiles . '/swap//'
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
if exists('+fixendofline')
  " When writing a file and this option is on, <EOL> at the end of file will be
  " restored if missing
  set nofixendofline
endif
" Override the 'ignorecase' if the search pattern contains upper case
set smartcase
" Don't redraw the screen while executing macros, registers and other commands
" that have not been typed
set lazyredraw
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
" S: do not show search count message when searching, e.g. "[1/5]"
set shortmess+=m
set shortmess+=r
set shortmess+=c
if has('patch-8.1.1270')
  set shortmess-=S
endif
" Exclude East Asian characters from spell checking
set spelllang-=cjk
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
if !has_key(g:plugs, 'FixCursorHold.nvim')
  " Update swap file and trigger CursorHold after 100ms
  set updatetime=100
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
  if exists('+completeslash')
    " A forward slash is used for path completion in insert mode
    set completeslash=slash
  else
    " Use a forward slash when expanding file names
    set shellslash
  endif
endif

" C
let g:c_comment_strings = 1

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

if has('syntax') && (has('gui_running') || &t_Co > 16)
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
    let f = s:ScreenFilename()
    if has('gui_running') && g:screen_size_restore_pos && filereadable(f)
      let vim_instance =
            \ (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      for line in readfile(f)
        let sizepos = split(line)
        if len(sizepos) == 5 && sizepos[0] == vim_instance
          silent! execute 'set columns=' . sizepos[1] . ' lines=' . sizepos[2]
          silent! execute 'winpos ' . sizepos[3] . ' ' . sizepos[4]
          return
        endif
      endfor
    endif
  endfunction
  function! s:ScreenSave()
    " Save window size and position.
    if has('gui_running') && g:screen_size_restore_pos
      let vim_instance =
            \ (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      let data = vim_instance . ' ' . &columns . ' ' . &lines . ' ' .
            \ (getwinposx() < 0 ? 0: getwinposx()) . ' ' .
            \ (getwinposy() < 0 ? 0: getwinposy())
      let f = s:ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        call filter(lines, "v:val !~ '^" . vim_instance . "\\>'")
        call add(lines, data)
      else
        let lines = [data]
      endif
      call writefile(lines, f)
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
  augroup NoCursorMoveOnFocus
    autocmd!
    autocmd FocusLost *
          \ let s:oldmouse = &mouse |
          \ set mouse=
    autocmd FocusGained *
          \ if get(s:, 'oldmouse', '') !=# '' |
          \   let &mouse = s:oldmouse |
          \   unlet s:oldmouse |
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
  " Sets how Vim performs indentation
  " lN: If N != 0 Vim will align with a case label instead of the statement
  "     after it in the same line
  " gN: Place C++ scope declarations N characters from the indent of the block
  "     they are in
  " hN: Place statements occurring after a C++ scope declaration N characters
  "     from the indent of the label
  " tN: Indent a function return type declaration N characters from the margin
  " (N: When in unclosed parentheses, indent N characters from the line with the
  "     unclosed parentheses
  "     When N is 0 or the unclosed parentheses is the first non-white character
  "     in its line, line up with the next non-white character after the
  "     unclosed parentheses
  " WN: When in unclosed parentheses and N is non-zero and either using "(0" or
  "     "u0", respectively and the unclosed parentheses is the last non-white
  "     character in its line and it is not the closing parentheses, indent the
  "     following line N characters relative to the outer context (i.e. start of
  "     the line or the next unclosed parentheses)
  " kN: When in unclosed parentheses which follow "if", "for" or "while" and N
  "     is non-zero, overrides the behaviour defined by "(N": causes the indent
  "     to be N characters relative to the outer context (i.e. the line where
  "     "if", "for" or "while" is)
  set cinoptions=l1,g0.5s,h0.5s,t0,(0,W2s,k2s
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

  " Reload .editorconfig because of heuristic detections done by vim-polyglot
  autocmd FileType c,cpp,perl
        \ setlocal shiftwidth=4 |
        \ :EditorConfigReload

  autocmd FileType go
        \ setlocal noexpandtab shiftwidth=4 tabstop=4

  " Plain view for plugins
  autocmd FileType GV,vim-plug
        \ setlocal colorcolumn= nolist textwidth=0

  autocmd FileType java,json
        \ setlocal shiftwidth=4

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
nnoremap <Space> ;

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
inoremap <C-A> <C-C>I
inoremap <expr> <C-E> pumvisible() ? "\<C-E>" : "\<End>"

" Close braces
function! s:CloseBrace()
  let line_num = line('.')
  let next_line = getline(line_num + 1)
  if col('.') != col('$')
    return "{\<CR>"
  elseif !empty(next_line) &&
        \ indent(line_num + 1) == indent(line_num) &&
        \ next_line =~# '^\s*}'
    return "{\<CR>"
  elseif (&filetype ==# 'c' || &filetype ==# 'cpp') &&
        \ getline(line_num) =~# '\%(' .
        \   '^\s*\%(typedef\s*\)\?\%(class\|enum\|struct\)\s\+' . '\|' .
        \   '\<\h\w*\s*=\s*$' . '\)'
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

" Go to tab page by number
for s:i in range(1, 9)
  execute 'nnoremap <Leader>' . s:i . ' ' . s:i . 'gt'
endfor
nnoremap <Leader>0 :tablast<CR>

" Reselect visual block after shifting
vnoremap < <gv
vnoremap > >gv

" Use CTRL-N to clear the highlighting
nnoremap <silent> <C-N> :<C-U>nohlsearch<C-R>=&diff ? '<Bar>diffupdate' : ''<CR><CR>

" Clear screen
nnoremap <Leader><C-L> <C-L>

" Search for visually selected text
function! s:VSearch(cmd)
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  normal! gvy
  let pat = escape(@", a:cmd . '\')
  let pat = substitute(pat, '\n', '\\n', 'g')
  let @/ = '\V' . pat
  normal! gV
  call setreg('"', old_reg, old_regtype)
endfunction
if has_key(g:plugs, 'vim-searchindex')
  vnoremap * :<C-U>call <SID>VSearch('/')<CR>/<C-R>/<CR>zz<Plug>SearchIndex
  vnoremap # :<C-U>call <SID>VSearch('?')<CR>?<C-R>/<CR>zz<Plug>SearchIndex
else
  vnoremap * :<C-U>call <SID>VSearch('/')<CR>/<C-R>/<CR>zz
  vnoremap # :<C-U>call <SID>VSearch('?')<CR>?<C-R>/<CR>zz
endif

" Center display after searching
if has_key(g:plugs, 'vim-searchindex')
  nmap <silent> n nzz<Plug>SearchIndex
  nmap <silent> N Nzz<Plug>SearchIndex
  nmap <silent> * *zz<Plug>SearchIndex
  nmap <silent> # #zz<Plug>SearchIndex
  nmap <silent> g* g*zz<Plug>SearchIndex
  nmap <silent> g# g#zz<Plug>SearchIndex
else
  function! s:CenterBeforeSearch(opposite)
    if @/ ==# ''
      return
    endif
    let backward = v:searchforward == a:opposite
    let flags = backward ? 'b' : ''
    for i in range(v:count1 - 1)
      call search(@/, flags)
    endfor
    let pos = searchpos(@/, flags . 'n')
    if pos != [0, 0] && pos[0] != line('.')
      if backward
        if !(pos[0] == line('$') && pos[1] >= col([line('$'), '$']) - 1)
          keepjumps call cursor(pos[0], col([pos[0], '$']) - 1)
          normal! zz
          if pos[1] >= col([pos[0], '$']) - 1
            keepjumps call cursor(pos[0] + 1, 1)
          endif
        endif
      else
        if pos != [1, 1]
          keepjumps call cursor(pos[0], 1)
          normal! zz
          if pos[1] == 1
            keepjumps call cursor(pos[0] - 1, col([pos[0] - 1, '$']) - 1)
          endif
        endif
      endif
    endif
  endfunction
  nnoremap n :<C-U>call <SID>CenterBeforeSearch(0)<CR>n
  nnoremap N :<C-U>call <SID>CenterBeforeSearch(1)<CR>N
  nnoremap * *zz
  nnoremap # #zz
  nnoremap g* g*zz
  nnoremap g# g#zz
endif

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
    let db = findfile('cscope.out', '.;')
    if !empty(db)
      silent cscope reset
      silent! execute 'cscope add' db
    elseif !empty($CSCOPE_DB)
      silent cscope reset
      silent! execute 'cscope add' $CSCOPE_DB
    endif
  endfunction

  set cscopetag
  set cscopetagorder=0
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
  nnoremap <C-\>s :cscope find s <C-R><C-W><CR>
  nnoremap <C-\>g :cscope find g <C-R><C-W><CR>
  nnoremap <C-\>d :cscope find d <C-R><C-W><CR>
  nnoremap <C-\>c :cscope find c <C-R><C-W><CR>
  nnoremap <C-\>t :cscope find t <C-R><C-W><CR>
  xnoremap <C-\>t y:cscope find t <C-R>"<CR>
  nnoremap <C-\>e :cscope find e <C-R><C-W><CR>
  nnoremap <C-\>f :cscope find f <C-R><C-F><CR>
  nnoremap <C-\>i :cscope find i ^<C-R><C-F>$<CR>
  nnoremap <C-\>a :cscope find a <C-R><C-W><CR>
endif

function! s:RemapBufferQ()
  nnoremap <buffer> q :q<CR>
endfunction

function! s:MapSaveAndRun(key, cmd)
  if a:cmd =~# '^make'
    let pre_make = 'let &l:cmdheight += 1<Bar>'
    let post_make = '<Bar>let &l:cmdheight -= 1'
  else
    let pre_make = ''
    let post_make = ''
  endif
  execute 'nnoremap <buffer> ' . a:key .
        \ ' :<C-U>w<CR>:' . pre_make . a:cmd . post_make . '<CR>'
  execute 'inoremap <buffer> ' . a:key .
        \ ' <Esc>:w<CR>:' . pre_make . a:cmd . post_make . '<CR>'
endfunction

function! s:MapCompilingRust()
  if strlen(findfile('Cargo.toml', '.;')) > 0
    " CompilerSet makeprg=cargo\ $*
    call s:MapSaveAndRun('<F5>', 'make build')
    call s:MapSaveAndRun('<F6>', 'make run')
  else
    " CompilerSet makeprg=rustc\ \%:S
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
        \   compiler gcc |
        \   setlocal makeprg=gcc\ -o\ %<\ % |
        \ endif
  autocmd FileType cpp
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   compiler gcc |
        \   setlocal makeprg=g++\ -o\ %<\ % |
        \ endif

  " Markdown code snippets
  autocmd FileType markdown inoremap <buffer> <LocalLeader>` ```

  " Go
  autocmd FileType go call s:MapSaveAndRun('<F5>', '!go run %')

  " Python
  autocmd FileType python call s:MapSaveAndRun('<F5>', '!python %')

  " Ruby
  " CompilerSet makeprg=ruby
  autocmd FileType ruby
        \ compiler ruby |
        \ call s:MapSaveAndRun('<F5>', 'make %')

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

" :CR
command! CR
      \ try |
      \   execute '%s/' . nr2char(13) . '\+$//g' |
      \ catch /^Vim\%((\a\+)\)\=:E486/ |
      \ finally |
      \   set fileformat=dos |
      \   write |
      \ endtry

" :GDiff
if has('win32')
  command! GDiff cexpr system('git diff \| diff-hunk-list.bat') |
        \ cwindow | wincmd p
else
  command! GDiff cexpr system('git diff \| diff-hunk-list') |
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
    let i = 1
    while i <= winnr('$')
      if a:quitpre && i == winnr()
        let i += 1
        continue
      endif
      let filetypes = ['help', 'qf', 'nerdtree', 'taglist']
      if index(filetypes, getbufvar(winbufnr(i), '&filetype')) >= 0 ||
            \ getwinvar(i, '&previewwindow')
        let i += 1
      else
        break
      endif
    endwhile
    if i == winnr('$') + 1
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
  if exists('*getcmdwintype')
    autocmd FocusGained,BufEnter * if getcmdwintype() ==# '' | checktime | endif
  else
    autocmd FocusGained,BufEnter * checktime
  endif
augroup END

" WSL
if has('unix') && executable('clip.exe')
  augroup AutoClipboard
    autocmd!
    autocmd TextYankPost *
          \ if v:event.operator ==# 'y' | call system('clip.exe', @0) | endif
  augroup END
endif

augroup FileTypeAutocmds
  autocmd!

  " Doxygen support
  autocmd FileType c,cpp setlocal syntax+=.doxygen

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
  autocmd BufNewFile,BufRead *.[sS] setlocal filetype=gas

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

" Automatically install missing plugins on startup
augroup VimPlug
  autocmd!
  autocmd VimEnter * call s:InstallMissingPlugins()
augroup END

augroup LoadVimrc
  autocmd!
  " Reload vimrc on the fly
  autocmd BufWritePost $MYVIMRC nested
        \ source $MYVIMRC |
        \ call s:InstallMissingPlugins()
augroup END

" Reload symlink of vimrc on the fly
let s:resolved_vimrc = resolve(expand($MYVIMRC))
if expand($MYVIMRC) !=# s:resolved_vimrc
  execute 'autocmd LoadVimrc BufWritePost ' . s:resolved_vimrc .
        \ ' nested source $MYVIMRC | call s:InstallMissingPlugins()'
endif

" }}}
" =============================================================================
" Plugins: {{{
" =============================================================================

" PreserveNoEOL
if has_key(g:plugs, 'PreserveNoEOL')
  let g:PreserveNoEOL = 1
endif

" vim-obsession
if has_key(g:plugs, 'tcd.vim')
  function! s:SaveTabInfo()
    if !exists('g:this_session')
      return
    endif

    let lines = []
    for tabnr in range(1, tabpagenr('$'))
      let tabvars = gettabvar(tabnr, '')
      for var in [
            \ 'tcd_ocwd', 'tcd_cwd'] " tcd.vim
        if has_key(tabvars, var)
          let val = tabvars[var]
          let lines += ['call settabvar(' .
                \ tabnr . ', ' .
                \ "'" . var . "', " .
                \ "'" . substitute(val, "'", "''", 'g') . "')"]
        endif
      endfor
    endfor

    if empty(lines)
      return
    endif

    let body = readfile(g:this_session)
    for line in lines
      call insert(body, line, -3)
    endfor
    call writefile(body, g:this_session)
  endfunction
  augroup ObsessionSaveTabInfo
    autocmd!
    autocmd User Obsession call s:SaveTabInfo()
  augroup END
endif

" FixCursorHold.nvim
let g:cursorhold_updatetime = 100

" vim-gutentags
function! s:BuildTagsFileListCmd(prog)
  let filetypes = [
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
    let cmd = 'git ls-files ' .
          \ join(map(filetypes, '"''*." . v:val . "''"'), ' ')
  elseif a:prog ==# 'hg'
    " hg files -I '**.c' -I '**.h'
    let cmd = 'hg files ' .
          \ join(map(filetypes, '"-I ''**." . v:val . "''"'), ' ')
  elseif a:prog ==# 'find'
    " find . -type f \( -name '*.c' -o -name '*.h' \)
    let cmd = 'find . -type f ' .
          \ '\( ' .
          \ join(map(filetypes, '"-name ''*." . v:val . "''"'), ' -o ') .
          \ ' \)'
  elseif a:prog ==# 'dir'
    " dir /S /B /A-D *.c *.h
    let cmd = 'dir /S /B /A-D ' .
          \ join(map(filetypes, '"*." . v:val'), ' ')
  endif

  return cmd
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
  nnoremap c<C-P> :History :<CR>
  if executable('rg')
    function! s:GetVisualSelection()
      let [line_start, column_start] = getpos("'<")[1:2]
      let [line_end, column_end] = getpos("'>")[1:2]
      let lines = getline(line_start, line_end)
      if len(lines) == 0
        return ''
      endif
      let offset = &selection ==# 'exclusive' ? 2 : 1
      let lines[-1] = lines[-1][:column_end - offset]
      let lines[0] = lines[0][column_start - 1:]
      return join(lines, "\n")
    endfunction
    let s:rg_common = 'rg --column --line-number --no-heading --color=always ' .
          \ '--smart-case '
    command! -bang -nargs=* Rg
          \ call fzf#vim#grep(
          \   s:rg_common . '--fixed-strings -- ' . shellescape(<q-args>),
          \   1,
          \   fzf#vim#with_preview(
          \     { 'options': '--delimiter : --nth 4..' }, 'right', 'ctrl-/'),
          \   <bang>0)
    command! -bang -nargs=+ -complete=dir Rgd
          \ call fzf#vim#grep(
          \   s:rg_common . '--fixed-strings -- ' . shellescape(''),
          \   1,
          \   fzf#vim#with_preview(
          \     { 'dir': fnamemodify(expand(<q-args>), ':p:h'),
          \       'options': '--delimiter : --nth 4..' },
          \     'right', 'ctrl-/'),
          \   <bang>0)
    command! -bang -nargs=* Rgr
          \ call fzf#vim#grep(
          \   s:rg_common . '-- ' . shellescape(<q-args>),
          \   1,
          \   fzf#vim#with_preview({ 'options': '--delimiter : --nth 4..' },
          \     'right', 'ctrl-/'),
          \   <bang>0)
    nnoremap <Leader>* :<C-U>Rg<Space><C-R><C-W><CR>
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
  let curline = getline('.')
  keepjumps call search('\V\^' . escape(curline, '\') . '\$', 'cw')
endfunction
augroup DirvishConfig
  autocmd!
  autocmd FileType dirvish silent! unmap <buffer> <C-N>
  autocmd FileType dirvish silent! unmap <buffer> <C-P>
  autocmd FileType dirvish call <SID>ResetDirvishCursor()
augroup END

" coc.nvim
if has_key(g:plugs, 'coc.nvim')
  call coc#config('suggest.minTriggerInputLength', 4)
  if has_key(g:plugs, 'echodoc.vim')
    call coc#config('suggest.echodocSupport', v:true)
  endif
  if has_key(g:plugs, 'ale')
    call coc#config('diagnostic.displayByAle', v:true)
  endif
  call coc#config('coc.preferences.semanticTokensHighlights', v:false)
  call coc#config('coc.preferences.bracketEnterImprove', v:false)

  " coc-clangd
  if executable('clangd')
    call coc#add_extension('coc-clangd')
  else
    let s:llvm_clangd_path = '/usr/local/opt/llvm/bin/clangd'
    if executable(s:llvm_clangd_path)
      call coc#config('clangd.path', s:llvm_clangd_path)
      call coc#add_extension('coc-clangd')
    endif
  endif

  " coc-pyright
  for s:linter in [
        \ 'flake8',
        \ 'bandit',
        \ 'mypy',
        \ 'pytype',
        \ 'prospector',
        \ 'pydocstyle',
        \ 'pylama',
        \ 'pylint']
    if executable(s:linter)
      call coc#config('python.linting.' . s:linter . 'Enabled', v:true)
    endif
  endfor
  unlet s:linter
  if has('python3')
    call coc#config('python.pythonPath', exepath('python3'))
  elseif has('python')
    call coc#config('python.pythonPath', exepath('python'))
  endif

  " coc-rust-analyzer
  if executable('rust-analyzer')
    call coc#config('rust-analyzer.server.path', exepath('rust-analyzer'))
    call coc#add_extension('coc-rust-analyzer')
  endif

  " coc-solargraph
  call coc#config('solargraph.promptDownload', v:false)
  if executable('solargraph')
    call coc#config('solargraph.diagnostics', v:true)
    call coc#add_extension('coc-solargraph')
  endif

  call coc#add_extension(
        \ 'coc-cmake',
        \ 'coc-css',
        \ 'coc-emoji',
        \ 'coc-json',
        \ 'coc-pyright',
        \ 'coc-tag')

  augroup CocFileType
    autocmd!
    autocmd FileType diff,mail,netrw,qf,tagbar,text
          \ let b:coc_enabled = 0
  augroup END

  command! -nargs=0 Format :call CocAction('format')
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
  let g:ale_hover_cursor = 0
  let g:ale_linters_ignore = {
        \ 'python': [
        \   'flake8',
        \   'mypy',
        \   'pylint',
        \   'pyright'] }
  if executable('rust-analyzer')
    let g:ale_linters_ignore['rust'] = ['cargo']
  endif
  let g:ale_set_highlights = 0

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
        \ '-cppcoreguidelines-avoid-magic-numbers',
        \ '-cppcoreguidelines-macro-usage',
        \ '-fuchsia-*',
        \ '-google-readability-todo',
        \ '-hicpp-no-assembler',
        \ '-hicpp-signed-bitwise',
        \ '-hicpp-uppercase-literal-suffix',
        \ '-llvm-*',
        \ '-llvmlibc-*',
        \ '-modernize-use-trailing-return-type',
        \ '-readability-else-after-return',
        \ '-readability-magic-numbers',
        \ '-readability-uppercase-literal-suffix']
  let g:ale_cpp_clangtidy_checks = g:ale_c_clangtidy_checks

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
  let g:syntastic_vim_checkers = ['vimlint', 'vint']
endif

" vim-endwise
augroup EndwiseCMake
  autocmd FileType cmake
        \ let b:endwise_addition = '\=submatch(0)==#toupper(submatch(0)) ? ' .
        \   '"END".submatch(0)."()" : "end".submatch(0)."()"' |
        \ let b:endwise_words = 'foreach,function,if,macro,while' |
        \ let b:endwise_pattern = '\%(\<end\>.*\)\@<!\<&\>' |
        \ let b:endwise_syngroups = 'cmakeStatement,cmakeCommandConditional,' .
        \   'cmakeCommandRepeat,cmakeCommand'
  autocmd FileType rbs
        \ let b:endwise_addition = 'end' |
        \ let b:endwise_words = 'module,class' |
        \ let b:endwise_pattern = '^\(.*=\)\?\s*\%(private\s\+\|protected\s\+\|public\s\+\|module_function\s\+\)*\zs\%(module\|class\)\>\%(.*[^.:@$]\<end\>\)\@!\|\<do\ze\%(\s*|.*|\)\=\s*$' |
        \ let b:endwise_syngroups = 'rbsDefine'
augroup END

" quick-scope
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" vim-wordmotion
let g:wordmotion_prefix = '<Leader>'

" bullets.vim
let g:bullets_enabled_file_types = [
      \ 'gitcommit',
      \ 'gitsendemail',
      \ 'markdown',
      \ 'text']
let g:bullets_pad_right = 0
let g:bullets_outline_levels = []
let g:bullets_checkbox_markers = ' ---x'

" vim-closetag
let g:closetag_filetypes = 'html,javascript.jsx,php,xhtml,xml'
let g:closetag_xhtml_filetypes = 'javascript.jsx,xhtml,xml'

" vim-unimpaired
let g:nremap = {}
" Center display on move
function! s:RemapUnimpairedToCenter()
  for [key, cmd] in [
        \ ['l', 'L'],
        \ ['q', 'Q'],
        \ ['t', 'T'],
        \ ['n', 'Context']]
    let plug_map = '\<Plug>unimpaired' . cmd
    execute 'nnoremap <silent> [' . key .
          \ ' :<C-U>execute "normal " . v:count1 . "' .
          \ plug_map . 'Previous"<CR>zz'
    execute 'nnoremap <silent> ]' . key .
          \ ' :<C-U>execute "normal " . v:count1 . "' .
          \ plug_map . 'Next"<CR>zz'
    let g:nremap['[' . key] = ''
    let g:nremap[']' . key] = ''
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
      \   'active': ['tabname', 'tabmodified'],
      \   'inactive': ['tabname', 'tabmodified'] },
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
for s:k in ['name', 'modified']
  let g:lightline.tab_component_function['tab' . s:k] =
        \ 'LightLineTab' . toupper(s:k[0]) . s:k[1:]
endfor

function! LightLineWide(component)
  let component_visible_width = {
        \ 'mode': 70,
        \ 'fileencoding': 70,
        \ 'fileformat': 70,
        \ 'filetype': 70,
        \ 'percent': 50 }
  return winwidth(0) >= get(component_visible_width, a:component, 0)
endfunction

function! LightLineVisible(component)
  let fname = expand('%:t')
  return fname !=# '__Tag_List__' &&
        \ fname !=# 'ControlP' &&
        \ fname !~# 'NERD_tree' &&
        \ LightLineWide(a:component)
endfunction

function! LightLineMode()
  let short_mode_map = {
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
  let fname = expand('%:t')
  return fname ==# '__Tag_List__' ? 'TagList' :
        \ fname ==# 'ControlP' ? 'CtrlP' :
        \ fname =~# 'NERD_tree' ? '' :
        \ LightLineWide('mode') ? lightline#mode() :
        \ get(short_mode_map, mode(), short_mode_map['?'])
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  let fpath = expand('%')
  return &filetype ==# 'dirvish' ?
        \   (fpath ==# getcwd() . '/' ? fnamemodify(fpath, ':~') :
        \   fnamemodify(fpath, ':~:.')) :
        \ &buftype ==# 'terminal' ? fpath :
        \ &filetype ==# 'fzf' ? 'fzf' :
        \ &filetype ==# 'vim-plug' ? fpath :
        \ fname ==# '__Tag_List__' ? '' :
        \ fname ==# 'ControlP' ? '' :
        \ fname =~# 'NERD_tree' ?
        \   (index(['" Press ? for help', '.. (up a dir)'], getline('.')) < 0 ?
        \     matchstr(getline('.'), '[0-9A-Za-z_/].*') : '') :
        \ '' !=# fname ? fnamemodify(fpath, ':~:.') : '[No Name]'
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

function! LightLineTabName(n)
  " tcd.vim
  let tabcwd = gettabvar(a:n, 'tcd_cwd')
  if !empty(tabcwd)
    return fnamemodify(tabcwd, ':p:~')
  elseif haslocaldir(-1, a:n) == 2
    return fnamemodify(getcwd(-1, a:n), ':p:~')
  else
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let fname = expand('#' . buflist[winnr - 1] . ':t')
    let filetype = gettabwinvar(a:n, winnr, '&filetype')
    return filetype ==# 'GV' ? 'GV' :
          \ '' !=# fname ? fname : '[No Name]'
  endif
endfunction

function! LightLineTabModified(n)
  " tcd.vim
  let tabcwd = gettabvar(a:n, 'tcd_cwd')
  if !empty(tabcwd)
    return ''
  elseif haslocaldir(-1, a:n) == 2
    return ''
  else
    let winnr = tabpagewinnr(a:n)
    return gettabwinvar(a:n, winnr, '&modified') ? '+' : ''
  endif
endfunction

function! LightLineFugitiveStatusline()
  if @% !~# '^fugitive:'
    return ''
  endif
  let head = FugitiveHead()
  if !len(head)
    return ''
  endif
  let commit = matchstr(FugitiveParse()[0], '^\x\+')
  if len(commit)
    return head . ':' . commit[0:6]
  else
    return head
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
    let counts = ale#statusline#Count(bufnr('%'))
    let errors = counts.error + counts.style_error
    let warnings = counts.total - errors
    let error_msg = errors ? printf('E(%d)', errors) : ''
    let warning_msg = warnings ? printf('W(%d)', warnings) : ''

    if errors && warnings
      return printf('%s %s', error_msg, warning_msg)
    else
      return errors ? error_msg : (warnings ? warning_msg : '')
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

" vim-searchindex
cnoremap <CR> <CR>

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

" vim-signify
if has_key(g:plugs, 'vim-signify')
  nnoremap <silent> [c :<C-U>execute 'normal ' . v:count1 . "\<Plug>(signify-prev-hunk)"<CR>zz
  nnoremap <silent> ]c :<C-U>execute 'normal ' . v:count1 . "\<Plug>(signify-next-hunk)"<CR>zz
  nnoremap <Leader>hp :<C-U>SignifyHunkDiff<CR>
  nnoremap <Leader>hu :<C-U>SignifyHunkUndo<CR>
endif

" vim-gitgutter
if has_key(g:plugs, 'vim-gitgutter')
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
  nnoremap <silent> [c :<C-U>execute 'normal ' . v:count1 . "\<Plug>(GitGutterPrevHunk)"<CR>zz
  nnoremap <silent> ]c :<C-U>execute 'normal ' . v:count1 . "\<Plug>(GitGutterNextHunk)"<CR>zz
endif

" goyo.vim
nnoremap <Leader>G :Goyo<CR>

" Colorizer
let g:colorizer_colornames = 0
let g:colorizer_disable_bufleave = 1

" adblock-filter.vim
let g:adblock_filter_auto_checksum = 1

" vim-gas
let g:gasCppComments = 1

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
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
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
    autocmd BufNewFile *.plist set filetype=xml
  augroup END
  " Disable default autocmds
  let g:loaded_plist = 1
  let g:plist_display_format = 'xml'
  let g:plist_save_format = ''
endif

" }}}
" =============================================================================
