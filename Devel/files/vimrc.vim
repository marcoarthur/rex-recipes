" set plugin and indent on
set nocompatible
filetype off
filetype plugin on
filetype indent on
syntax on
set shiftwidth=4
set tabstop=4
" set autoindent
set expandtab
" set cindent
set bg=dark
set showcmd
set nu
set title
set history=1000
set modeline
set laststatus=2
set colorcolumn=81
set clipboard=unnamedplus
set diffopt=vertical
set rtp+=~/.fzf
set rtp+=~/.vim/bundle/Vundle.vim
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn','\%81v', 100)


" searching in web 
function! WebSearch (engine, ...)
    let sep = ' '
    let query = ''
    
    "concat the query
    for q in a:000
        let query .= sep . q
    endfor

    "run search
    exec "!g.sh " . a:engine . sep . query
endfunction

" Copy from the clipboard
function! PasteMe()
    set paste
    normal "*p
    set nopaste
endfunction

"noremap # :call SearchWord()<CR>
noremap ; :
noremap : ;

" Handle Tabs
noremap H :tabpreviou<CR>
noremap L :tabnext<CR>
noremap <leader>nn :tabnew .<CR>


" Maps
" All Pasting: paste file to parcellite
nmap <leader>ap :!parcellite < % <CR><CR>

set omnifunc=syntaxcomplete#Complete

" set the compilation option for latex files
let g:Tex_FormatDependency_pdf = 'dvi,ps,pdf'
let g:Tex_CompileRule_dvi      = 'latex --interaction=nonstopmode $*'
let g:Tex_CompileRule_ps       = 'dvips -Ppdf -o $*.ps $*.dvi'
let g:Tex_CompileRule_pdf      = 'ps2pdf $*.ps'


" disable dbext maps in *.pm files
au BufReadPre,BufNewFile,FileReadPre *.pm let g:dbext_default_usermaps = 0


" set the maximum column width for result window
let g:dbext_DBI_max_column_width = 200

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:showmarks_enable=0

" paste it from clipboard in paste mode
noremap <leader>p :set paste<CR>"*p:set nopaste<CR>

" vim-plug
call plug#begin('~/.vim/plugged')
if has('nvim')
    Plug 'github/copilot.vim'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug 'ervandew/supertab'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'ibhagwan/fzf-lua'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/lightline.vim'
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'janko/vim-test'
Plug 'jiangmiao/auto-pairs'
Plug 'jremmen/vim-ripgrep'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'majutsushi/tagbar'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'metakirby5/codi.vim'
Plug 'metakirby5/codi.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'posva/vim-vue'
Plug 'powerman/vim-plugin-viewdoc'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'projectfluent/fluent.vim'
Plug 'sainnhe/sonokai'
Plug 'sebdah/vim-delve'
Plug 'sheerun/vim-polyglot'
Plug 'skywind3000/asyncrun.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-rmarkdown'
Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny' }
Plug 'vim-syntastic/syntastic'
Plug 'yegappan/taglist'
call plug#end()

"=============================================================================

colorscheme sonokai 
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

"
" Vim eslint
"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline^=%{coc#status()}

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exe = 'npm run lint --'

"
" autoclose
"
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.svelte'

"
" Pandoc
"
let g:pandoc#filetypes#handled = ["pandoc", "markdown"]

" Mappings
noremap <silent> <F3> :FZF<CR>
noremap <silent> <F11> :tabnew ~/.vimrc<CR>
noremap <silent> <F9> :make<CR>
noremap <silent> ff :FZF!<CR>
noremap <silent> \a :set autochdir<CR>

"
" Perl specifications
"
let perl_sub_signatures = 1
let g:Perl_Perltidy  = 'on'
" include POD marks in the taglist in Tag Window
let tlist_perl_settings   = 'perl;c:constants;f:formats;l:labels;p:packages;'.
                        \ 's:subroutines;d:subroutines;o:POD;t:Keyword Comments'


if has('nvim')
    nnoremap <leader>ff <cmd>Telescope find_files<cr>
    nnoremap <leader>fg <cmd>Telescope live_grep<cr>
    nnoremap <leader>fb <cmd>Telescope buffers<cr>
    nnoremap <leader>fh <cmd>Telescope help_tags<cr>
endif

if executable("rg")
    set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
    set grepformat=%f:%l:%c:%m
endif

set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
