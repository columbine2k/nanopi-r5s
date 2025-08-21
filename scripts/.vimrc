" === VimPlug  ===================================
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" === 基础 =======================================
set nocompatible
set backspace=indent,eol,start
set history=2000
set autoread
set magic
set title
" 语法
syntax on
filetype on
filetype plugin on
filetype indent on
" tab
set expandtab
set smarttab
set shiftround
" 缩进
set autoindent smartindent shiftround
set shiftwidth=4
set tabstop=4
set softtabstop=4

" === 编辑 =======================================
" 写入延迟
set updatetime=100
" 鼠标
" set mouse=a
" 系统剪切板
set clipboard^=unnamed,unnamedplus
" 编码
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set termencoding=utf-8
set ffs=unix,dos,mac
set formatoptions+=m
set formatoptions+=B
" 选择
set selectmode=mouse,key
set selection=exclusive
autocmd FileType markdown,text set selection=inclusive
" 自动删除行尾空白
autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

" === 显示 =======================================
" 光标
set cursorcolumn
set cursorline
" 界面
set ruler
set number
set relativenumber
set nowrap
set showcmd
set showmode
set showmatch
set matchtime=2
set splitright
set splitbelow
" 滚动保留
set scrolloff=7
" 搜索
set hlsearch
set incsearch
set ignorecase
set smartcase

" === 个性 =======================================
" 主题
set termguicolors
set background=dark
" 标记栏颜色
hi! link SignColumn   LineNr
hi! link ShowMarksHLl DiffAdd
hi! link ShowMarksHLu DiffChange

" === 键位 =======================================
" 主键
let mapleader=' '
let g:mapleader=' '
" Netrw
nmap <leader>e :Ex<CR>
" 取消高亮
nmap <leader>n :nohl<CR>
" 新增窗口
nmap <leader>sv <C-w>v
nmap <leader>sh <C-w>s
" buffer 切换
nmap <leader>] :bnext<CR>
nmap <leader>[ :bprevious<CR>
" 单行或多行移动
vmap K :m '<-2<CR>gv=gv
vmap J :m '>+1<CR>gv=gv
vmap H <gv
vmap L >gv
" fzf
nmap <leader>f :FZF<CR>
nmap <leader>b :Buffers<CR>

" === 插件 =======================================
call plug#begin('~/.vim/plugged')
" 主题
Plug 'sainnhe/everforest'
" 状态栏
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" 注释
Plug 'tpope/vim-commentary'
" 缩进线
Plug 'nathanaelkane/vim-indent-guides'
" 命令提示
Plug 'gelguy/wilder.nvim'
" 窗口切换
Plug 'christoomey/vim-tmux-navigator'
" git
Plug 'airblade/vim-gitgutter'
" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" lsp 自动补全
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
" 图标 (保持最后一个加载)
Plug 'ryanoasis/vim-devicons'
call plug#end()

" === 配置 =======================================
" 主题
let g:everforest_background="hard"
let g:everforest_enable_italic=1
let g:airline_theme="everforest"
colorscheme everforest
" 状态栏
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
" 缩进线
let g:indent_guides_enable_on_vim_startup = 1
" 命令提示
call wilder#setup({
    \ 'modes': [':', '/', '?'],
    \ })
call wilder#set_option('renderer', wilder#popupmenu_renderer({
    \ 'highlighter': wilder#basic_highlighter(),
    \ }))
call wilder#set_option('renderer', wilder#renderer_mux({
    \ ':': wilder#popupmenu_renderer(),
    \ '/': wilder#wildmenu_renderer(),
    \ }))
call wilder#set_option('renderer', wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    \ 'highlights': {
    \   'border': 'Normal',
    \ },
    \ 'border': 'rounded',
    \ })))
" fzf
let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['right,50%', 'ctrl-/']
" vim-lsp 配置
if executable('pylsp')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
        \ })
endif
" asyncomplete Tab 补全
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
