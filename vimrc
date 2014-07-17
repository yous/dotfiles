" Vundle
se nocp " nocompatible
if has('gui_running') || has('unix')
  au FileType vundle setl nossl " autocmd setlocal noshellslash
  filet off " filetype
  se rtp+=~/.vim/bundle/Vundle.vim " set runtimepath
  cal vundle#begin() " call
  " Let vundle manage itself
  Plugin 'gmarik/Vundle.vim'
  " Colorscheme
  Plugin 'wombat256.vim'
  Plugin 'chriskempson/tomorrow-theme', {'rtp': 'vim/'}
  " Status, tabline
  Plugin 'bling/vim-airline'
  " ANSI escape
  Plugin 'AnsiEsc.vim'
  " ConqueTerm
  " Plugin 'Conque-Shell'
  Plugin 'yous/conque'
  " Preserve missing EOL at the end of text files
  Plugin 'PreserveNoEOL'
  " Autocomplete if end
  Plugin 'tpope/vim-endwise'
  " Extended % matching
  Plugin 'matchit.zip'
  " HTML5
  Plugin 'othree/html5.vim'
  " PHP
  Plugin 'php.vim-html-enhanced'
  " Jade
  Plugin 'digitaltoad/vim-jade'
  " XML
  Plugin 'othree/xml.vim'
  " TomDoc
  Plugin 'wellbredgrapefruit/tomdoc.vim'
  " Cucumber
  Plugin 'tpope/vim-cucumber'
  " auto-close
  Plugin 'Townk/vim-autoclose'
  " rubycomplete
  if has('ruby')
    Plugin 'rubycomplete.vim'
  en
  " Faster HTML code writing
  Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
  " Easily delete, change and add surroundings in pairs
  Plugin 'tpope/vim-surround'
  " Much simpler way to use some motions
  Plugin 'Lokaltog/vim-easymotion'
  " Vim sugar for the UNIX shell commands
  Plugin 'tpope/vim-eunuch'
  " Switch between source files and header files
  Plugin 'a.vim'
  " Compile errors
  Plugin 'scrooloose/syntastic'
  " Markdown
  Plugin 'godlygeek/tabular'
  Plugin 'plasticboy/vim-markdown'
  " JSON
  Plugin 'elzr/vim-json'
  " Racket
  Plugin 'wlangstroth/vim-racket'
  " Git wrapper
  Plugin 'tpope/vim-fugitive'
  " Rails
  Plugin 'tpope/vim-rails'
  " Coffee script
  Plugin 'kchmck/vim-coffee-script'
  " Explore filesystem
  Plugin 'scrooloose/nerdtree'
  " Full path finder
  Plugin 'kien/ctrlp.vim'
  " LaTeX
  Plugin 'LaTeX-Suite-aka-Vim-LaTeX'
  cal vundle#end()
en " endif
filet plugin indent on

" General
if &shell =~# 'fish$'
  se sh=sh " shell
en
if has('gui_running')
  colo wombat256mod " colorscheme
  se enc=utf-8 " encoding
  se go-=m " guioptions Menu bar
  se go-=T " Toolbar
  se go-=r " Right-hand scrollbar
  se go-=L " Left-hand scrollbar when there is a vertically split window
  se mouse=
  so $VIMRUNTIME/delmenu.vim " source
  se lm=ko.UTF-8 " langmenu
  so $VIMRUNTIME/menu.vim
elsei has('unix') " elseif
  colo Tomorrow-Night-Eighties
en
if has('win32')
  au InsertEnter * se noimd " noimdisable
  au InsertLeave * se imd " imdisable
  au FocusGained * se imd
  au FocusLost * se noimd
  lan mes en " language messages en
  se dir=.,$TEMP " directory
  se ssl " shellslash
en
au InsertLeave * se nopaste
se bs=2 " backspace indent,eol,start
se cb=unnamed " clipboard
se fencs=ucs-bom,utf-8,cp949,latin1 " fileencodings
se ffs=unix,mac,dos " fileformats
se ic " ignorecase # for smartcase
se is " incsearch
se nobk " nobackup
se scs " smartcase
se wmnu " wildmenu
sy on " syntax

" Vim UI
if has('gui_running')
  se gfn=DejaVu\ Sans\ Mono:h10:cANSI " guifont
  if has('win32')
    se gfw=DotumChe:h10:cDEFAULT " guifontwide
  en
  fu! ScreenFilename() " function
    if has('amiga')
      retu 's:.vimsize' " return
    elsei has('win32')
      retu $HOME.'\_vimsize'
    el " else
      retu $HOME.'/.vimsize'
    en
  endf " endfunction
  fu! ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let f = ScreenFilename()
    if has('gui_running') && g:screen_size_restore_pos && filereadable(f)
      let vim_instance = (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      for line in readfile(f)
        let sizepos = split(line)
        if len(sizepos) == 5 && sizepos[0] == vim_instance
          " silent! execute
          sil! exe 'set columns='.sizepos[1].' lines='.sizepos[2]
          sil! exe 'winpos '.sizepos[3].' '.sizepos[4]
          retu
        en
      endfo " endfor
    en
  endf
  fu! ScreenSave()
    " Save window size and position.
    if has('gui_running') && g:screen_size_restore_pos
      let vim_instance = (g:screen_size_by_vim_instance == 1 ? (v:servername) : 'GVIM')
      let data = vim_instance.' '.&columns.' '.&lines.' '.
            \ (getwinposx() < 0 ? 0: getwinposx()).' '.
            \ (getwinposy() < 0 ? 0: getwinposy())
      let f = ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        cal filter(lines, "v:val !~ '^".vim_instance."\\>'")
        cal add(lines, data)
      el
        let lines = [data]
      en
      cal writefile(lines, f)
    en
  endf
  if !exists('g:screen_size_restore_pos')
    let g:screen_size_restore_pos = 1
  en
  if !exists('g:screen_size_by_vim_instance')
    let g:screen_size_by_vim_instance = 1
  en
  au VimEnter * if g:screen_size_restore_pos == 1 | cal ScreenRestore() | en
  au VimLeavePre * if g:screen_size_restore_pos == 1 | cal ScreenSave() | en
en
se bg=dark " background
se dy+=uhex " display # show unprintable characters as a hex number
se hls " hlsearch # search with highlight
se ls=2 " laststatus
se nu " number
se sb " splitbelow
se sc " showcmd
se sm " showmatch
se so=3 " scrolloff
se spr " splitright
se title
se t_Co=256
if exists('+colorcolumn')
  se cc=80 " colorcolumn
el
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
en

" Highlight trailing whitespace
" highlight
hi ExtraWhitespace ctermbg=red guibg=red
" match
au BufWinEnter * mat ExtraWhitespace /\s\+$/
au InsertEnter * mat ExtraWhitespace //
au InsertLeave * mat ExtraWhitespace /\s\+$/
if version >= 702
  au BufWinLeave * cal clearmatches()
en

" Text formatting
au FileType * setl fo-=c fo-=o " setlocal formatoptions # disable automatic comment insertion
au FileType c,cpp,java,mkd,markdown,python setl sts=4 sw=4 ts=4
se ai " autoindent
se et " expandtab
se si " smartindent
se sts=2 " softtabstop
se sw=2 " shiftwidth
se ts=2 " tabstop

" Mappings
map j gj
map k gk
map <DOWN> gj
map <UP> gk
" inoremap
ino {<CR> {<CR>}<ESC>O

" Center display after searching
" nnoremap
nn n nzz
nn N Nzz
nn * *zz
nn # #zz
nn g* g*zz
nn g# g#zz

" Reselect visual block after shifting
" vnoremap
vn < <gv
vn > >gv

" Splitted windows
nn <C-J> <C-W>j
nn <C-K> <C-W>k
nn <C-H> <C-W>h
nn <C-L> <C-W>l

" Tab
map <C-T> :tabnew<CR>
if has('win32')
  map <C-TAB> :tabnext<CR>
  map <C-S-TAB> :tabprevious<CR>
elsei has('unix')
  map t :tabnext<CR>
  map T :tabprevious<CR>
en

" Global copy and paste for Mac OS X
if has('unix')
  let s:uname = system('uname')
  if s:uname == "Darwin\n"
    " nmap
    nm <F2> :.w !pbcopy<CR><CR>
    " vmap
    vm <F2> :w !pbcopy<CR><CR>
    nm <F3> :se paste<CR>:r !pbpaste<CR>:se nopaste<CR>
    " imap
    im <F3> <ESC>:se paste<CR>:r !pbpaste<CR>:se nopaste<CR>
  en
en

" C, C++ compile & execute
au FileType c,cpp map <F5> :w<CR>:make %<CR>
au FileType c,cpp im <F5> <ESC>:w<CR>:make %<CR>
au FileType c
      \ if !filereadable('Makefile') && !filereadable('makefile') |
      \   setl mp=gcc\ -o\ %< | " makeprg
      \ en
au FileType cpp
      \ if !filereadable('Makefile') && !filereadable('makefile') |
      \   setl mp=g++\ -o\ %< |
      \ en
if has('win32')
  map <F6> :!%<.exe<CR>
  im <F6> <ESC>:!%<.exe<CR>
elsei has('unix')
  map <F6> :!./%<<CR>
  im <F6> <ESC>:!./%<<CR>
en

" Python execute
au FileType python map <F5> :w<CR>:!python %<CR>
au FileType python im <F5> <ESC>:w<CR>:!python %<CR>

" Ruby execute
au FileType ruby map <F5> :w<CR>:!ruby %<CR>
au FileType ruby im <F5> <ESC>:w<CR>:!ruby %<CR>

" man page settings
au FileType c,cpp se kp=man " keywordprg
au FileType ruby se kp=ri

" Ruby configuration files view
au BufNewFile,BufRead Gemfile,Guardfile setl ft=ruby " filetype

" Gradle view
au BufNewFile,BufRead *.gradle setf groovy " setfiletype

" Json view
au BufNewFile,BufRead *.json setf json

" ANSI escape for Rails log
au FileType railslog :AnsiEsc

" mobile.erb view
aug rails_subtypes " augroup
  au!
  au BufNewFile,BufRead *.mobile.erb let b:eruby_subtype = 'html'
  au BufNewFile,BufRead *.mobile.erb setf eruby
aug END

" ConqueTerm
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_ReadUnfocused = 1
au FileType conque_term hi clear ExtraWhitespace
" command
com -nargs=* Sh ConqueTerm <args>
com -nargs=* Shsp ConqueTermSplit <args>
com -nargs=* Shtab ConqueTermTab <args>
com -nargs=* Shvs ConqueTermVSplit <args>

" PreserveNoEOL
let g:PreserveNoEOL = 1

" rubycomplete
au FileType ruby set ofu=rubycomplete#Complete

" EasyMotion
let g:EasyMotion_leader_key = '<Leader>'

" Markdown Vim Mode
let g:vim_markdown_folding_disabled = 1

" Fugitive
let s:fugitive_insert = 0
au FileType gitcommit if byte2line(2) == 2 |
      \   let s:fugitive_insert = 1 |
      \ en
au VimEnter * if (s:fugitive_insert) |
      \   start |
      \ en " startinsert
au FileType gitcommit let s:open_nerdtree = 0
au FileType gitrebase let s:open_nerdtree = 0

" NERD Tree
let s:open_nerdtree = 1
if &diff
  let s:open_nerdtree = 0
en
au VimEnter * if (s:open_nerdtree) |
      \   NERDTree |
      \   winc p |
      \ en
au BufEnter * if (winnr('$') == 1 && exists('b:NERDTreeType') && b:NERDTreeType == 'primary') |
      \   q |
      \ en

" LaTeX-Suite-aka-Vim-LaTeX
let g:tex_flavor = 'latex'
if has('win32')
  se gp=findstr\ /n\ /s " grepprg
elsei has('unix')
  se gp=grep\ -nH\ $*
en
se isk+=: " iskeyword
" Change default mappings for IMAP_Jumpfunc
if exists('g:Imap_StickyPlaceHolders') && g:Imap_StickyPlaceHolders
  vm <C-Space> <Plug>IMAP_JumpForward
el
  vm <C-Space> <Plug>IMAP_DeleteAndJumpForward
en
im <C-Space> <Plug>IMAP_JumpForward
nm <C-Space> <Plug>IMAP_JumpForward
