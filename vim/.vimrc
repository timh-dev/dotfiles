set nocompatible       
filetype off               

" set the runtime path to include Vundle and initialize
set backspace=indent,eol,start
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'morhetz/gruvbox'
Plugin 'kaicataldo/material.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-surround'
Plugin 'yggdroot/indentline'
Plugin 'lervag/vimtex'
Plugin 'junegunn/goyo.vim'
Plugin 'JuliaEditorSupport/julia-vim'
Plugin 'sainnhe/everforest'

call vundle#end()           
filetype plugin indent on  

" Syntax highlighting
syntax enable
filetype plugin indent on  

" settings
set number
set noswapfile
set hlsearch
set ignorecase
set incsearch
set spell spelllang=en_us

" color schemes
set background=dark
colorscheme everforest

" Remap
nnoremap <buffer> <F9> :w <bar> :exec '!python3' shellescape(@%, 1)<cr>

set tabstop=4
set shiftwidth=4
set expandtab

" Custom conceal
syntax match todoCheckbox "\[\ \]" conceal cchar=
syntax match todoCheckbox "\[x\]" conceal cchar=
syntax match todoCheckbox "\[-\]" conceal cchar=☒
syntax match todoCheckbox "\[\.\]" conceal cchar=⊡
syntax match todoCheckbox "\[o\]" conceal cchar=⬕
let b:current_syntax = "todo"
hi! link todoCheckbox normal
set conceallevel=2
