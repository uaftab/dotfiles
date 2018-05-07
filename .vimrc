set nocompatible                                "Make vimrc not compatible with vi 
set modelines=0                                 "Prevent security exploits in modelines

" Tab settings 
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2                                "Display the status line
set relativenumber                              "Show relative linenumber of how far each line is form cursor line
set number                                      "Show line number of cursor line
set undofile                                    "Create an undofile to make undo function presists after close/reopen
syntax on                                       "Turn on syntax highlighting

"Searching/Moving functions
set ignorecase
set smartcase
set gdefault
set showmatch
set hlsearch

