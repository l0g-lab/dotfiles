" vim configuration file

let mapleader = " "
colorscheme murphy

" Auto-install plug-vim
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -s -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter + PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
\| endif

" Plugins
call plug#begin()
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" configure expanding of tabs for various file types
au BufRead,BufNewFile *.py set expandtab
au BufRead,BufNewFile *.c set expandtab
au BufRead,BufNewFile *.h set expandtab
au BufRead,BufNewFile Makefile* set noexpandtab

set expandtab                   " enter spaces when tab is pressed
set textwidth=120               " break lines when line length increases
set tabstop=4                   " use 4 spaces to represent tab
set softtabstop=4
set shiftwidth=4 smarttab       " number of spaces to use for auto indent
set autoindent                  " copy indent from current line when starting new line
set backspace=indent,eol,start  " make backspaces more powerfull
set ruler                       " show line and column number
syntax on                       " syntax highlighting
filetype on                     " enable filetype detection
filetype plugin on              " enable filetype plugins
filetype indent on              " enable filetype-based indenting
set showcmd                     " show (partial) command in status line
set number                      " show line numbers
set relativenumber              " show relative line numbers

" Remaps
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>gs :GFiles?<CR>
nnoremap <leader>r :Rg<CR>
nnoremap <leader>b :Buffer<CR>
nnoremap <leader>w :Windows<CR>


" FZF plugin config
let g:fzf_layout = { 'down': '~40%' }
