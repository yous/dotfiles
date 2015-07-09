" vim-plug
" --------

set nocompatible
filetype off

" Install vim-plug if it isn't installed and call plug#begin() out of box
function! s:DownloadVimPlug()
  if !empty(&rtp)
    let vimfiles = split(&rtp, ',')[0]
  else
    echohl ErrorMsg
    echomsg 'Unable to determine runtime path for Vim.'
    echohl NONE
    return
  endif
  if empty(glob(vimfiles . '/autoload/plug.vim'))
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

      if !isdirectory(vimfiles . '/autoload')
        call mkdir(vimfiles . '/autoload', 'p')
      endif
      call rename(new, vimfiles . '/autoload/plug.vim')

      " Install plugins at first
      autocmd VimEnter * PlugInstall | quit
    finally
      if isdirectory(tmp)
        let dir = '"' . escape(tmp, '"') . '"'
        silent call system(has('win32') ? 'rmdir /S /Q ' : 'rm -rf ' . dir)
      endif
    endtry
  endif
  call plug#begin(vimfiles . '/plugged')
endfunction

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

call s:DownloadVimPlug()

" Colorscheme
Plug 'yous/tomorrow-theme', { 'branch': 'revert-git-summary-bold',
      \ 'rtp': 'vim' }

" General
if has('python')
  redir => pyv
  silent python import platform; print(platform.python_version())
  redir END

  " PreserveNoEOL requires Python 2.6
  if s:VersionRequirement(
        \ map(split(split(pyv)[0], '\.'), 'str2nr(v:val)'), [2, 6])
    " Preserve missing EOL at the end of text files
    Plug 'PreserveNoEOL'
  endif
endif
" EditorConfig
Plug 'editorconfig/editorconfig-vim'
" Full path finder
Plug 'kien/ctrlp.vim'
" Go to Terminal or File manager
Plug 'justinmk/vim-gtfo'
" Much simpler way to use some motions
Plug 'Lokaltog/vim-easymotion'
" Extended % matching
Plug 'matchit.zip'
" Autocomplete if end
Plug 'tpope/vim-endwise'
" Easily delete, change and add surroundings in pairs
Plug 'tpope/vim-surround'
" Pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'
" Vim sugar for the UNIX shell commands
Plug 'tpope/vim-eunuch'
" Produce increasing/decreasing columns of numbers, dates, or daynames
Plug 'visincr'
" Syntax checking plugin
Plug 'scrooloose/syntastic'
" Switch between source files and header files
Plug 'a.vim'
" Automated tag file generation and syntax highlighting of tags
Plug 'xolox/vim-misc'
Plug 'xolox/vim-easytags'
" Git wrapper
Plug 'tpope/vim-fugitive'
" Enable repeating supported plugin maps with "."
Plug 'tpope/vim-repeat'
" Distraction-free writing in Vim
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }

" Vim UI
" Status, tabline
Plug 'bling/vim-airline'
" Explore filesystem
Plug 'scrooloose/nerdtree'
" Source code browser
Plug 'taglist.vim'
" Show a git diff in the gutter and stages/reverts hunks
Plug 'airblade/vim-gitgutter'

" ConqueTerm
" Plug 'Conque-Shell'
Plug 'yous/conque', { 'on': [
      \ 'ConqueTerm',
      \ 'ConqueTermSplit',
      \ 'ConqueTermVSplit',
      \ 'ConqueTermTab'] }

" Support file types
" AdBlock
Plug 'mojako/adblock-filter.vim', { 'for': 'adblockfilter' }
" Aheui
Plug 'yous/aheui.vim', { 'for': 'aheui' }
" Coffee script
Plug 'kchmck/vim-coffee-script', { 'for': 'coffee' }
" Crystal
Plug 'rhysd/vim-crystal', { 'for': 'crystal' }
" Cucumber
Plug 'tpope/vim-cucumber', { 'for': 'cucumber' }
" Dockerfile
Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }
" HTML5
Plug 'othree/html5.vim'
" Jade
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
" JavaScript
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
" JSON
Plug 'elzr/vim-json', { 'for': 'json' }
" JSX
Plug 'mxw/vim-jsx', { 'for': 'javascript.jsx' }
" Liquid
Plug 'tpope/vim-liquid'
" Markdown
Plug 'godlygeek/tabular', { 'for': 'mkd' }
Plug 'plasticboy/vim-markdown', { 'for': 'mkd' }
" PHP
Plug 'php.vim-html-enhanced'
" Racket
Plug 'wlangstroth/vim-racket', { 'for': 'racket' }
" XML
Plug 'othree/xml.vim', { 'for': 'xml' }

" Ruby
" Rake
Plug 'tpope/vim-rake'
" RuboCop
Plug 'ngmy/vim-rubocop', { 'on': 'RuboCop' }
" Rails
Plug 'tpope/vim-rails'
" ANSI escape
Plug 'AnsiEsc.vim', { 'for': 'railslog' }
" TomDoc
Plug 'wellbredgrapefruit/tomdoc.vim', { 'for': 'ruby' }

" Mac OS
if has('mac') || has('macunix')
  " Launch queries for Dash.app from inside Vim
  Plug 'rizzatti/dash.vim', { 'on': [
        \ 'Dash',
        \ 'DashKeywords',
        \ '<Plug>DashSearch',
        \ '<Plug>DashGlobalSearch'] }
endif

call plug#end()
filetype plugin indent on
syntax on

" General
" -------

" Define the 'vimrc' autocmd group
augroup vimrc
  autocmd!
augroup END

if &shell =~# 'fish$'
  set shell=sh
endif
set autoread
set background=dark
set backspace=indent,eol,start
" Use the clipboard register '*'
set clipboard=unnamed
set fileencodings=ucs-bom,utf-8,cp949,latin1
set fileformats=unix,mac,dos
" Number of remembered ":" commands
set history=1000
" Ignore case in search
set ignorecase
" Show where the pattern while typing a search command
set incsearch
" Don't make a backup before overwriting a file
set nobackup
" Override the 'ignorecase' if the search pattern contains upper case
set smartcase
" Enable list mode
set list
" Strings to use in 'list' mode and for the :list command
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
" The key sequence that toggles the 'paste' option
set pastetoggle=<F2>
" Maximum number of changes that can be undone
set undolevels=1000
" List of file patterns to ignore when expanding wildcards, completing file or
" directory names, and influences the result of expand(), glob() and globpath()
set wildignore+=.git,.hg,.svn
set wildignore+=*.bmp,*.gif,*.jpeg,*.jpg,*.png
set wildignore+=*.dll,*.exe,*.o,*.obj
set wildignore+=*.sw?
set wildignore+=*.DS_Store
set wildignore+=*.pyc
if exists('&wildignorecase')
  " Ignore case when completing file names and directories
  set wildignorecase
endif
" Enhanced command-line completion
set wildmenu

if has('win32')
  " Enable the Input Method only on Insert mode
  autocmd vimrc InsertEnter * set noimdisable
  autocmd vimrc InsertLeave * set imdisable
  autocmd vimrc FocusGained * set imdisable
  autocmd vimrc FocusLost * set noimdisable
  language messages en
  " Directory names for the swap file
  set directory=.,$TEMP
  " Use a forward slash when expanding file names
  set shellslash
endif
" Exit Paste mode when leaving Insert mode
autocmd vimrc InsertLeave * set nopaste

" Vim UI
" ------

if has('gui_running') && &t_Co > 16
  " Highlight the screen line of the cursor
  set cursorline
endif
" Show as much as possible of the last line
set display+=lastline
" Show unprintable characters as a hex number
set display+=uhex
set hlsearch
" Always show a status line
set laststatus=2
set number
" Don't consider octal number when using the CTRL-A and CTRL-X commands
set nrformats-=octal
set scrolloff=3
" Show command in the last line of the screen
set showcmd
" Briefly jump to the matching one when a bracket is inserted
set showmatch
" The minimal number of columns to scroll horizontally
set sidescroll=1
set sidescrolloff=10
set splitbelow
set splitright
set title

colorscheme Tomorrow-Night

augroup colorcolumn
  autocmd!
  if exists('+colorcolumn')
    set colorcolumn=81
  else
    autocmd BufWinEnter * let w:m2 = matchadd('ErrorMsg', '\%>80v.\+', -1)
  endif
augroup END

" GUI
" ---

if has('gui_running')
  set encoding=utf-8
  set guifont=Consolas:h10:cANSI
  set guioptions-=m " Menu bar
  set guioptions-=T " Toolbar
  set guioptions-=r " Right-hand scrollbar
  set guioptions-=L " Left-hand scrollbar when window is vertically split

  source $VIMRUNTIME/delmenu.vim
  set langmenu=ko.UTF-8
  source $VIMRUNTIME/menu.vim

  if has('win32')
    set guifontwide=NanumGothicCoding:h10:cDEFAULT,DotumChe:h10:cDEFAULT
  endif

  function! s:ScreenFilename()
    if has('amiga')
      return 's:.vimsize'
    elseif has('win32')
      return $HOME.'\_vimsize'
    else
      return $HOME.'/.vimsize'
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
          silent! execute 'set columns='.sizepos[1].' lines='.sizepos[2]
          silent! execute 'winpos '.sizepos[3].' '.sizepos[4]
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
      let data = vim_instance.' '.&columns.' '.&lines.' '.
            \ (getwinposx() < 0 ? 0: getwinposx()).' '.
            \ (getwinposy() < 0 ? 0: getwinposy())
      let f = s:ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        call filter(lines, "v:val !~ '^".vim_instance."\\>'")
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
endif

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd vimrc BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd vimrc InsertEnter * match ExtraWhitespace //
autocmd vimrc InsertLeave * match ExtraWhitespace /\s\+$/
if version >= 702
  autocmd vimrc BufWinLeave * call clearmatches()
endif

" Text formatting
" ---------------

set autoindent
set expandtab
" Insert only one space after a '.', '?' and '!' with a join command
set nojoinspaces
set smartindent
" Number of spaces that a <Tab> counts for while editing
set softtabstop=2
" Number of spaces to use for each setp of (auto)indent
set shiftwidth=2
" Number of spaces that a <Tab> in the file counts for
set tabstop=2
autocmd vimrc FileType c,cpp,java,mkd,markdown,python
      \ setlocal softtabstop=4 shiftwidth=4 tabstop=4
" c: Disable automatic comment insertion on auto-wrap
" o: Disable automatic comment insertion on hitting 'o' or 'O' in normal mode
" j: Remove a comment leader when joining lines
autocmd vimrc FileType *
      \ setlocal formatoptions-=c |
      \ setlocal formatoptions-=o |
      \ setlocal formatoptions+=j
" Automatic formatting of paragraphs in 80 column
autocmd vimrc FileType mkd,markdown
      \ setlocal textwidth=80

" Mappings
" --------

" Commander
nnoremap ; :

" We do line wrap
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
noremap gj j
noremap gk k
noremap H ^
noremap L $

" Unix shell behavior
inoremap <C-A> <ESC>I
inoremap <C-E> <ESC>A
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" Break the undo block when Ctrl-u
inoremap <C-U> <C-G>u<C-U>

" Move cursor between splitted windows
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l

" Auto close brackets
inoremap (<CR> (<CR>)<ESC>O
inoremap [<CR> [<CR>]<ESC>O
inoremap {<CR> {<CR>}<ESC>O

" Reselect visual block after shifting
vnoremap < <gv
vnoremap > >gv

" Search regex
" All ASCII characters except 0-9, a-z, A-Z and '_' have a special meaning
nnoremap / /\v
vnoremap / /\v
cnoremap %s/ %smagic/
cnoremap \>s/ \>smagic/

" Stop the highlighting for hlsearch
nnoremap <silent> ,/ :nohlsearch<CR>

" Search for visually selected text
vnoremap * y/<C-R>"<CR>
vnoremap # y?<C-R>"<CR>

" Center display after searching
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Zoom and restore window
function! s:ZoomToggle()
  if exists('t:zoomed') && t:zoomed
    execute t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <Leader>z :ZoomToggle<CR>

" Help
function! s:SetHelpMapping()
  nnoremap <buffer> q :q<CR>
endfunction
autocmd vimrc FileType help call s:SetHelpMapping()

" Quickfix
function! s:SetQuickfixMapping()
  nnoremap <buffer> q :ccl<CR>
endfunction
autocmd vimrc FileType qf call s:SetQuickfixMapping()

" Auto quit Vim when actual files are closed
function! s:CheckLeftBuffers()
  if tabpagenr('$') == 1
    let i = 1
    while i <= winnr('$')
      if getbufvar(winbufnr(i), '&buftype') == 'help' ||
            \ getbufvar(winbufnr(i), '&buftype') == 'quickfix' ||
            \ exists('t:NERDTreeBufName') &&
            \   bufname(winbufnr(i)) == t:NERDTreeBufName ||
            \ bufname(winbufnr(i)) == '__Tag_List__'
        let i += 1
      else
        break
      endif
    endwhile
    if i == winnr('$') + 1
      call feedkeys(":qall\<CR>", 'n')
    endif
  endif
endfunction
autocmd vimrc BufEnter * call s:CheckLeftBuffers()

" C, C++ compile & execute
augroup vimrc
  autocmd FileType c,cpp map <F5> :w<CR>:make %<CR>
  autocmd FileType c,cpp imap <F5> <ESC>:w<CR>:make %<CR>
  autocmd FileType c
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   setlocal makeprg=gcc\ -o\ %< |
        \ endif
  autocmd FileType cpp
        \ if !filereadable('Makefile') && !filereadable('makefile') |
        \   setlocal makeprg=g++\ -o\ %< |
        \ endif
augroup END
if has('win32')
  map <F6> :!%<.exe<CR>
  imap <F6> <ESC>:!%<.exe<CR>
elseif has('unix')
  map <F6> :!./%<<CR>
  imap <F6> <ESC>:!./%<<CR>
endif

augroup vimrc
  " Python execute
  autocmd FileType python map <F5> :w<CR>:!python %<CR>
  autocmd FileType python imap <F5> <ESC>:w<CR>:!python %<CR>

  " Ruby execute
  autocmd FileType ruby map <F5> :w<CR>:!ruby %<CR>
  autocmd FileType ruby imap <F5> <ESC>:w<CR>:!ruby %<CR>

  " man page settings
  autocmd FileType c,cpp set keywordprg=man
  autocmd FileType ruby set keywordprg=ri

  " Ruby configuration files view
  autocmd BufNewFile,BufRead Gemfile,Guardfile setlocal filetype=ruby

  " Gradle view
  autocmd BufNewFile,BufRead *.gradle setlocal filetype=groovy

  " Json view
  autocmd BufNewFile,BufRead *.json setlocal filetype=json

  " zsh-theme view
  autocmd BufNewFile,BufRead *.zsh-theme setlocal filetype=zsh
augroup END

" mobile.erb view
augroup rails_subtypes
  autocmd!
  autocmd BufNewFile,BufRead *.mobile.erb let b:eruby_subtype = 'html'
  autocmd BufNewFile,BufRead *.mobile.erb setfiletype eruby
augroup END

" Plugins
" -------

" PreserveNoEOL
let g:PreserveNoEOL = 1

" EasyMotion
let g:EasyMotion_leader_key = '<Leader>'

" unimpaired.vim
" Center display on move between SCM conflicts
nnoremap [n [nzz
nnoremap ]n ]nzz

" Syntastic
" Display all of the errors from all of the checkers together
let g:syntastic_aggregate_errors = 1
" Check header files
let g:syntastic_c_check_header = 1
let g:syntastic_cpp_check_header = 1
" Extend max error count for JSLint
let g:syntastic_javascript_jslint_args = '--white --nomen --regexp --plusplus
      \ --bitwise --newcap --sloppy --vars --maxerr=1000'

" easytags
let g:easytags_auto_highlight = 0

" Fugitive
let s:fugitive_insert = 0
augroup colorcolumn
  autocmd FileType gitcommit
        \ if exists('+colorcolumn') |
        \   set colorcolumn=73 |
        \ else |
        \   let w:m2 = matchadd('ErrorMsg', '\%>72v.\+', -1) |
        \ endif
augroup END
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
autocmd vimrc FileType gitcommit let s:open_sidebar = 0
autocmd vimrc FileType gitrebase let s:open_sidebar = 0

" goyo.vim
nnoremap <Leader>G :Goyo<CR>

" airline
let g:airline_left_sep = ''
let g:airline_right_sep = ''
if !empty(&t_Co) && &t_Co > 16
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_min_count = 2
endif

" NERD Tree and Tag List
let s:open_sidebar = 1
" Windows Vim
if !empty(&t_Co) && &t_Co <= 16
  let s:open_sidebar = 0
endif
if &diff
  let s:open_sidebar = 0
endif
let Tlist_Inc_Winwidth = 0

function! s:OpenSidebar()
  if !exists(':NERDTree') || !exists(':TlistOpen')
    return
  endif
  NERDTree
  TlistOpen
  wincmd J
  wincmd W
  wincmd L
  NERDTreeFocus
  normal AA
  wincmd p
endfunction

autocmd vimrc VimEnter *
      \ if (s:open_sidebar) |
      \   call s:OpenSidebar() |
      \ endif

" ConqueTerm
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_ReadUnfocused = 1
autocmd vimrc FileType conque_term highlight clear ExtraWhitespace
command! -nargs=* Sh ConqueTerm <args>
command! -nargs=* Shsp ConqueTermSplit <args>
command! -nargs=* Shtab ConqueTermTab <args>
command! -nargs=* Shvs ConqueTermVSplit <args>

" Adblock
let g:adblock_filter_auto_checksum = 1

" vim-json
let g:vim_json_syntax_conceal = 0

" Markdown Vim Mode
let g:vim_markdown_folding_disabled = 1

" Rake
nmap <Leader>ra :Rake<CR>

" RuboCop
let g:vimrubocop_extra_args = '--display-cop-names'
let g:vimrubocop_keymap = 0
nmap <Leader>ru :RuboCop<CR>

" ANSI escape for Rails log
autocmd vimrc FileType railslog :AnsiEsc

" Mac OS
if has('mac') || has('macunix')
  " dash.vim
  let g:dash_map = {
        \   'java' : 'android'
        \ }
  nmap <Leader>d <Plug>DashSearch
endif
