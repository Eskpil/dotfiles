syntax on 
filetype on
filetype indent on 

set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set relativenumber
set laststatus=2

 
call plug#begin('~/.vim/plugged')

Plug 'rust-lang/rust.vim',
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'itchyny/lightline.vim'
Plug 'morhetz/gruvbox' 
Plug 'shinchu/lightline-gruvbox.vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'vim-pandoc/vim-pandoc'
Plug 'rwxrob/vim-pandoc-syntax-simple'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

call plug#end() 

let g:pandoc#formatting#mode = 'h' " A'
let g:pandoc#formatting#textwidth = 72

autocmd BufRead,BufNewFile *.porth set filetype=porth
autocmd BufRead,BufNewFile *.cjs set filetype=javascript

let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'helloworld' ] ]
      \ },
      \ 'component': {
      \   'helloworld': 'Hello, world!'
      \ },
      \ }

syntax on
colorscheme gruvbox
set background=dark
