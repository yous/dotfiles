" Vundle
set nocompatible
if has('gui_running') || has('unix')
  autocmd FileType vundle setlocal noshellslash
  filetype off
  set runtimepath+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
  " Let vundle manage itself
  Plugin 'gmarik/Vundle.vim'

  " Colorscheme
  Plugin 'wombat256.vim'
  " Plugin 'altercation/vim-colors-solarized'
  Plugin 'khwon/vim-tomorrow-theme'

  " General
  " Preserve missing EOL at the end of text files
  Plugin 'PreserveNoEOL'
  " ANSI escape
  Plugin 'AnsiEsc.vim'
  " Full path finder
  Plugin 'kien/ctrlp.vim'
  " Much simpler way to use some motions
  Plugin 'Lokaltog/vim-easymotion'
  " Extended % matching
  Plugin 'matchit.zip'
  " Autocomplete if end
  Plugin 'tpope/vim-endwise'
  " Easily delete, change and add surroundings in pairs
  Plugin 'tpope/vim-surround'
  " Vim sugar for the UNIX shell commands
  Plugin 'tpope/vim-eunuch'
  " Compile errors
  Plugin 'scrooloose/syntastic'
  " Switch between source files and header files
  Plugin 'a.vim'
  " Git wrapper
  Plugin 'tpope/vim-fugitive'

  " Vim UI
  " Status, tabline
  Plugin 'bling/vim-airline'
  " Explore filesystem
  Plugin 'scrooloose/nerdtree'

  " ConqueTerm
  " Plugin 'Conque-Shell'
  Plugin 'yous/conque'

  " VimShell
  Plugin 'Shougo/vimproc.vim'
  Plugin 'Shougo/vimshell.vim'

  " Support file types
  " AdBlock
  Plugin 'mojako/adblock-filter.vim'
  " Coffee script
  Plugin 'kchmck/vim-coffee-script'
  " Cucumber
  Plugin 'tpope/vim-cucumber'
  " Jade
  Plugin 'digitaltoad/vim-jade'
  " JSON
  Plugin 'elzr/vim-json'
  " HTML5
  Plugin 'othree/html5.vim'
  " LaTeX
  Plugin 'LaTeX-Suite-aka-Vim-LaTeX'
  " Markdown
  Plugin 'godlygeek/tabular'
  Plugin 'plasticboy/vim-markdown'
  " PHP
  Plugin 'php.vim-html-enhanced'
  " Racket
  Plugin 'wlangstroth/vim-racket'
  " TomDoc
  Plugin 'wellbredgrapefruit/tomdoc.vim'
  " XML
  Plugin 'othree/xml.vim'

  " Ruby
  " Rake
  Plugin 'tpope/vim-rake'
  " RuboCop
  Plugin 'ngmy/vim-rubocop'
  " Rails
  Plugin 'tpope/vim-rails'
  call vundle#end()
endif
filetype plugin indent on
syntax on

" General
if &shell =~# 'fish$'
  set shell=sh
endif
set background=dark
set backspace=indent,eol,start
set clipboard=unnamed
set fileencodings=ucs-bom,utf-8,cp949,latin1
set fileformats=unix,mac,dos
set ignorecase " for smartcase
set incsearch
set nobackup
set smartcase
set wildignore+=.git,.hg,.svn
set wildignore+=*.bmp,*.gif,*.jpeg,*.jpg,*.png
set wildignore+=*.dll,*.exe,*.o,*.obj
set wildignore+=*.sw?
set wildignore+=*.DS_Store
set wildignore+=*.pyc
set wildmenu
if has('gui_running')
  colorscheme wombat256mod
  set encoding=utf-8
  set guioptions-=m " Menu bar
  set guioptions-=T " Toolbar
  set guioptions-=r " Right-hand scrollbar
  set guioptions-=L " Left-hand scrollbar when window is vertically split
  set mouse=
  source $VIMRUNTIME/delmenu.vim
  set langmenu=ko.UTF-8
  source $VIMRUNTIME/menu.vim
elseif has('unix')
  " colorscheme solarized
  colorscheme Tomorrow-Night-Eighties
endif
if has('win32')
  autocmd InsertEnter * set noimdisable
  autocmd InsertLeave * set imdisable
  autocmd FocusGained * set imdisable
  autocmd FocusLost * set noimdisable
  language messages en
  set directory=.,$TEMP
  set shellslash
endif
autocmd InsertLeave * set nopaste

" Vim UI
set display+=uhex " show unprintable characters as a hex number
set hlsearch " search with highlight
set laststatus=2
set number
set scrolloff=3
set showcmd
set showmatch
set sidescroll=1
set sidescrolloff=10
set splitbelow
set splitright
set title
set t_Co=256
augroup colorcolumn
  autocmd!
  if exists('+colorcolumn')
    set colorcolumn=81
  else
    autocmd BufWinEnter * let w:m2 = matchadd('ErrorMsg', '\%>80v.\+', -1)
  endif
augroup END
if has('gui_running')
  set guifont=DejaVu\ Sans\ Mono:h10:cANSI
  if has('win32')
    set guifontwide=DotumChe:h10:cDEFAULT
  endif
  function! ScreenFilename()
    if has('amiga')
      return 's:.vimsize'
    elseif has('win32')
      return $HOME.'\_vimsize'
    else
      return $HOME.'/.vimsize'
    endif
  endfunction
  function! ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let f = ScreenFilename()
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
  function! ScreenSave()
    " Save window size and position.
    if has('gui_running') && g:screen_size_restore_pos
      let vim_instance =
            \ (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      let data = vim_instance.' '.&columns.' '.&lines.' '.
            \ (getwinposx() < 0 ? 0: getwinposx()).' '.
            \ (getwinposy() < 0 ? 0: getwinposy())
      let f = ScreenFilename()
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
  autocmd VimEnter *
        \ if g:screen_size_restore_pos == 1 |
        \   call ScreenRestore() |
        \ endif
  autocmd VimLeavePre *
        \ if g:screen_size_restore_pos == 1 |
        \   call ScreenSave() |
        \ endif
endif

" Highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace //
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
if version >= 702
  autocmd BufWinLeave * call clearmatches()
endif

" Text formatting
set autoindent
set expandtab
set smartindent
set softtabstop=2
set shiftwidth=2
set tabstop=2
autocmd FileType c,cpp,java,mkd,markdown,python
      \ setlocal softtabstop=4 shiftwidth=4 tabstop=4
" Disable automatic comment insertion
autocmd FileType *
      \ setlocal formatoptions-=c formatoptions-=o

" Mappings
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
noremap gj j
noremap gk k
noremap H ^
noremap L $
inoremap <C-A> <ESC>I
inoremap <C-E> <ESC>A
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" Help
function SetHelpMapping()
  nnoremap <buffer> q :q<CR>
endfunction
autocmd FileType help call SetHelpMapping()
autocmd BufEnter *
      \ if winnr('$') == 1 &&
      \     getbufvar(winbufnr(winnr()), '&buftype') == 'help' |
      \   q |
      \ endif

" Quickfix
function SetQuickfixMapping()
  nnoremap <buffer> q :ccl<CR>
endfunction
autocmd FileType qf call SetQuickfixMapping()
autocmd BufEnter *
      \ if winnr('$') == 1 &&
      \     getbufvar(winbufnr(winnr()), '&buftype') == 'quickfix' |
      \   q |
      \ endif

" Search regex
nnoremap / /\v
vnoremap / /\v
cnoremap %s/ %smagic/
cnoremap \>s/ \>smagic/

" Auto close
inoremap (<CR> (<CR>)<ESC>O
inoremap [<CR> [<CR>]<ESC>O
inoremap {<CR> {<CR>}<ESC>O

" Center display after searching
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Reselect visual block after shifting
vnoremap < <gv
vnoremap > >gv

" Splitted windows
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l

" Tab
map <C-T> :tabnew<CR>
if has('win32')
  map <C-Tab> :tabnext<CR>
  map <C-S-Tab> :tabprevious<CR>
elseif has('unix')
  map t :tabnext<CR>
  map T :tabprevious<CR>
endif

" Global copy and paste for Mac OS X
if has('unix')
  let s:uname = system('uname')
  if s:uname == "Darwin\n"
    nmap <F2> :.w !pbcopy<CR><CR>
    vmap <F2> :w !pbcopy<CR><CR>
    nmap <F3> :se paste<CR>:r !pbpaste<CR>:se nopaste<CR>
    imap <F3> <ESC>:se paste<CR>:r !pbpaste<CR>:se nopaste<CR>
  endif
endif

" C, C++ compile & execute
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
if has('win32')
  map <F6> :!%<.exe<CR>
  imap <F6> <ESC>:!%<.exe<CR>
elseif has('unix')
  map <F6> :!./%<<CR>
  imap <F6> <ESC>:!./%<<CR>
endif

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

" ANSI escape for Rails log
autocmd FileType railslog :AnsiEsc

" mobile.erb view
augroup rails_subtypes
  autocmd!
  autocmd BufNewFile,BufRead *.mobile.erb let b:eruby_subtype = 'html'
  autocmd BufNewFile,BufRead *.mobile.erb setfiletype eruby
augroup END

" PreserveNoEOL
let g:PreserveNoEOL = 1

" EasyMotion
let g:EasyMotion_leader_key = '<Leader>'

" Fugitive
let s:fugitive_insert = 0
augroup colorcolumn
  autocmd!
  autocmd FileType gitcommit
        \ if exists('+colorcolumn') |
        \   set colorcolumn=73 |
        \ else |
        \   let w:m2 = matchadd('ErrorMsg', '\%>72v.\+', -1) |
        \ endif
augroup END
autocmd FileType gitcommit
      \ if byte2line(2) == 2 |
      \   let s:fugitive_insert = 1 |
      \ endif
autocmd VimEnter *
      \ if (s:fugitive_insert) |
      \   startinsert |
      \ endif
autocmd FileType gitcommit let s:open_nerdtree = 0
autocmd FileType gitrebase let s:open_nerdtree = 0

" airline
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" NERD Tree
let s:open_nerdtree = 1
if &diff
  let s:open_nerdtree = 0
endif
autocmd VimEnter *
      \ if (s:open_nerdtree) |
      \   NERDTree |
      \   wincmd p |
      \ endif
autocmd BufEnter *
      \ if winnr('$') == 1 &&
      \     exists('b:NERDTreeType') && b:NERDTreeType == 'primary' |
      \   q |
      \ endif

" ConqueTerm
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_ReadUnfocused = 1
autocmd FileType conque_term highlight clear ExtraWhitespace
command -nargs=* Sh ConqueTerm <args>
command -nargs=* Shsp ConqueTermSplit <args>
command -nargs=* Shtab ConqueTermTab <args>
command -nargs=* Shvs ConqueTermVSplit <args>

" VimShell
command Irb VimShellInteractive irb
command Birb VimShellInteractive bundle exec irb
command Python VimShellInteractive python

" Adblock
let g:adblock_filter_auto_checksum = 1

" LaTeX-Suite-aka-Vim-LaTeX
let g:tex_flavor = 'latex'
if has('win32')
  set grepprg=findstr\ /n\ /s
elseif has('unix')
  set grepprg=grep\ -nH\ $*
endif
set iskeyword+=:
" Change default mappings for IMAP_Jumpfunc
if exists('g:Imap_StickyPlaceHolders') && g:Imap_StickyPlaceHolders
  vmap <C-Space> <Plug>IMAP_JumpForward
else
  vmap <C-Space> <Plug>IMAP_DeleteAndJumpForward
endif
imap <C-Space> <Plug>IMAP_JumpForward
nmap <C-Space> <Plug>IMAP_JumpForward

" Markdown Vim Mode
let g:vim_markdown_folding_disabled = 1

" Rake
nmap <Leader>ra :Rake<CR>
