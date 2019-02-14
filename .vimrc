"vim:ts=4:sw=4:fdc=0:fdl=99
set nocompatible

" Mostly looks unnecessary but the filetype settings are useful.
source $VIMRUNTIME/vimrc_example.vim

" Remaps too many keys that I want to use in a *nix terminal.
"source $VIMRUNTIME/mswin.vim


"-----------------------------------------------------------------------------
" Setup Pathogen
"-----------------------------------------------------------------------------
execute pathogen#infect()


"-----------------------------------------------------------------------------
" Automatically remove fugitive buffers when they are not in use.
"-----------------------------------------------------------------------------
autocmd BufReadPost fugitive://* set bufhidden=delete

" turn off vim-json plugin syntax concealment in json files.
let g:vim_json_syntax_conceal = 0

if has("win32")
	behave mswin

	" read in my colours and default colours from the files 
	let s:my_colours = readfile($VIM . "\\vimfiles\\rgb.txt") 
	let s:rgb_file = readfile($VIMRUNTIME . "\\rgb.txt") 

	let s:added_colours = 0 

	" for each of my colours 
	for s:my_colour in s:my_colours 
    	let s:found=0 
    	" for each of the default colours... 
    	for s:line in s:rgb_file 
        	"...found my colour? 
        	if s:line =~ s:my_colour 
            	let s:found=1 
            	break 
        	endif 
    	endfor 

    	"if didn't find my colour... 
    	if s:found==0 
        	" ... add it to the default colours 
        	let s:rgb_file += [s:my_colour] 
        	let s:added_colours += 1 
    	endif 
	endfor 

	" if we changed the default colours, update the file 
	if s:added_colours > 0 
    	call writefile(s:rgb_file, $VIMRUNTIME . "\\rgb.txt") 
	endif 

    "-------------------------------------------------------------------------
    " Diff setup.
    "-------------------------------------------------------------------------
    " It would be better to fix the vim source code to 
    " recognize the 'iblank' parameter to diffopt but 
    " until I can do that this global variable will work.
    let g:iblank=0

    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        if &diffopt =~ 'iblank' | let opt = opt . '-w ' | endif
        if &diffopt =~ 'vertical' | let opt = opt . '-w ' | endif
        if g:iblank =~ 1 | let opt = opt . '-w ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '/<cmd'
                let cmd = '""' . $VIMRUNTIME . '/diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '/diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '/diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction

    set diffexpr=MyDiff()

    if has("gui")
	    noremap <C-Up> :resize +1<CR>
	    noremap <C-Down> :resize -1<CR>
	    noremap <C-Left> :vertical resize -1<CR>
	    noremap <C-Right> :vertical resize +1<CR>
    else
	    noremap <C-K> :resize +1<CR>
	    noremap <C-J> :resize -1<CR>
	    noremap <C-Left> :vertical resize -1<CR>
	    noremap <C-Right> :vertical resize +1<CR> " CTRL-L is already used for redraw.
    endif
else
	nnoremap <C-J> <C-W><C-J>
	nnoremap <C-K> <C-W><C-K>
	nnoremap <C-L> <C-W><C-L>
	nnoremap <C-H> <C-W><C-H>
endif


" ---------------------------------------------------------------------------
" Disable highlighting of curly brace errors inside [] and () 
" except in the first column.  This prevents C++ lambdas from 
" being flagged as syntax errors. 
" ---------------------------------------------------------------------------
let c_no_curly_error = 1


" ---------------------------------------------------------------------------
"  Local Modifications
" ---------------------------------------------------------------------------
let g:load_doxygen_syntax=1


" ---------------------------------------------------------------------------
"  Change colorscheme when running vimdiff from inside vim.
" ---------------------------------------------------------------------------
au FilterWritePre * if &diff | colorscheme astronaut | endif


" ---------------------------------------------------------------------------
" vim -b : edit binary using xxd-format!
" ---------------------------------------------------------------------------
augroup Binary
    au!
    au BufReadPre   *.bin,*.rgb,*.exe let &bin=1
    au BufReadPost  *.bin,*.rgb,*.exe if &bin | %!xxd
    au BufReadPost  *.bin,*.rgb,*.exe set ft=xxd | endif
    au BufWritePre  *.bin,*.rgb,*.exe if &bin | %!xxd -r
    au BufWritePre  *.bin,*.rgb,*.exe endif
    au BufWritePost *.bin,*.rgb,*.exe if &bin | %!xxd
    au BufWritePost *.bin,*.rgb,*.exe set nomod | endif
augroup END


" ---------------------------------------------------------------------------
" Using cscope_map.vim plugin.
" ---------------------------------------------------------------------------
if has("cscope")
	set nocsverb

	set csprg=gtags-cscope
	
	" add any database in current directory
	if filereadable("GTAGS")
    	cs add GTAGS
	endif

	set csverb
	
	" csto=0 to search cscope befor ctags
	" csto=1 to search ctags before cscope
	set csto=0
	
	set cst

    " Put search results in the quickfix buffer.
    " - flag indicates search command results are replaced rather than
    "   appended to previous results.
    set cscopequickfix=s-,c-,d-,i-,t-,e-

	" Using 'CTRL-\' then a search type makes the vim window
	" "shell-out", with search results displayed on the bottom

	"nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
	"nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	"nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

	" Using 'CTRL-spacebar' then a search type makes the vim window
	" split horizontally, with search result displayed in
	" the new window.
	"nnoremap <C-[>s :scs find s <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[>g :scs find g <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[>c :scs find c <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[>t :scs find t <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[>e :scs find e <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
	"nnoremap <C-[>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	"nnoremap <C-[>d :scs find d <C-R>=expand("<cword>")<CR><CR>

	" Hitting CTRL-space *twice* before the search type does a vertical
	" split instead of a horizontal one
	"nnoremap <C-[><C-[>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[><C-[>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[><C-[>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[><C-[>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[><C-[>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
	"nnoremap <C-[><C-[>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
	"nnoremap <C-[><C-[>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
endif " cscope

" Read .vimrc from the current directory.
" Can be used to store project specific settings.
set exrc

set diffopt=filler,iwhite,vertical

set tabpagemax=15

" Used when switching buffers such as jumping from quickfix to error lines.
" The full set of options is:
" useopen - use existing open buffer
" usetab - use existing open buffer even in a different tab
" split - split before opening buffer in a new window
" newtab - overrides split by opening buffer in a new tab
set switchbuf=useopen

set laststatus=2
"set statusline=%<%n\ %t\ %(%h%m%r%y%)\ %=%b\ 0x%B\ \ %l,%c%V\ %P
set statusline=%<%n\ %t\ %{fugitive#statusline()}\ %{ObsessionStatus()}\ %(%h%m%r%y%)\ %=%b\ 0x%B\ \ %l,%c%V\ %P

syn region myFold start="{" end="}" transparent fold
syn sync fromstart

" Do not automatically set pwd to directory of current file.
set noautochdir
" Set local working directory to path of current file unless path is /tmp.
"autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif

set path+=../..,../../..,
set magic
set noautoread
set nowrap
set linebreak
set nolist
set listchars=eol:$,tab:+-,trail:-,extends:>,precedes:<,nbsp:%
set nobackup
set autowrite

set cindent
"set cinkeys=
set cinwords=if,else,while,do,for,switch,try,catch
set cinoptions=>s,es,ns,f0,{0,}0,^0,L-1,:0,=s,l1,b0,g0,hs,N-s,t0,is,+s,c1,C1,/0,(0,W4,u0,U1

set tabstop=4
set shiftwidth=4
set noexpandtab
set noautoindent
set smartindent
set smarttab
set copyindent
set preserveindent
set nopaste " set paste to turn off all formating for pasting from the clipboard.
"set softtabstop=4 " Use a mix of tabs and spaces to act as if tabstop were set to this value.

set nosplitright
set scrolljump=1
set scrolloff=3
set sidescroll=1
set signcolumn=no " default scl=auto
set nowrapscan
set noincsearch
set grepprg=ag\ --ignore-dir\ build\ --ignore-dir\ builds\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m
set makeprg=make
set nocursorline
set nocursorcolumn
set undolevels=2048
set noequalalways
set textwidth=0
set winwidth=1
set wildignore=tags,cscope*,*.o,.git,commit.log,diff.txt,session.vim,*.swp
set wildmenu

set foldenable
set foldmethod=syntax
set foldcolumn=0
set foldlevel=99

if has("gui")
    set guioptions=egt

	if has("unix")
		set mouse=vcr
		set guifont=Monospace\ 9
	else
		set term=win32
		set mouse=a
    	set lines=60
   		set columns=199
    	set guifont=Consolas:h11:b:cANSI

        noremap <C-A-Left> :tabprevious<CR>
        noremap <C-A-Right> :tabnext<CR>
        noremap <S-C-A-Left> :tabfirst<CR>
        noremap <S-C-A-Right> :tablast<CR>

        noremap <A-Up> <C-W>k
        noremap <A-Down> <C-W>j
        noremap <A-Left> <C-W>h
        noremap <A-Right> <C-W>l
	endif

    "set guifont=Consolas:h9:b:cANSI
    "set guifont=Fixedsys:h9:cANSI
    "set guifont=Lucida_Console:h9:cANSI
    "set guifont=Lucida_Sans_Typewriter:h9:cANSI
    "set guifont=Lucida_Sans_Typewriter:h9:cANSI
    "set guifont=Terminal:h6:cOEM
    "set guifont=DejaVu_Sans_Mono:h9:b:cANSI
	"set guifont=Source_Code_Pro:h9:cANSI
	"set guifont=Anonymous_Pro:h9:cANSI
 
    set foldlevel=99
    set foldcolumn=1
    set foldmethod=syntax

    colorscheme Mustang
else
	if &diff
		colorscheme astronaut
	else
		colorscheme koehler
	endif
endif

set sessionoptions=curdir,folds,resize,slash,tabpages,winpos,winsize

" Load header file from directory above the .cpp file (:help filename-modifiers).
"noremap _hh :new %:p:h/../%:r:r.h
"noremap _HH :vnew %:p:h/../%:r:r.h

noremap! <F1> <Esc> "Turn off help key - too close to escape on notebook keyboard.
"nnoremap <F2> :!clang-format
"noremap <F3>
nnoremap <F4> :GundoToggle<CR>

"noremap <F5>
"noremap <F6>
"noremap <F7> 
"noremap <F8>

noremap <F9> :cprevious<CR>
noremap <F10> :cnext<CR>
noremap <F11> :set nohlsearch<CR>
noremap <F12> :set hlsearch<CR>

"noremap <C-F7> :1,%!Uncrustify.exe -q -c c:\uncrustify.cfg

noremap <S-Up> <C-W>_
noremap <S-Down> :resize 1<<CR>
noremap <S-Left> :exe 'vertical resize ' . (&columns / 2)<CR>
noremap <S-Right> :vertical resize 139<CR>

noremap <C-S-Left> :exe 'vertical resize ' &columns<CR>
noremap <C-S-Right> :exe 'vertical resize ' &columns<CR>

if has("win32")
    if has("gui")
	    noremap <C-Up> :resize +1<CR>
	    noremap <C-Down> :resize -1<CR>
	    noremap <C-Left> :vertical resize -1<CR>
	    noremap <C-Right> :vertical resize +1<CR>
    else
	    noremap <C-K> :resize +1<CR>
	    noremap <C-J> :resize -1<CR>
	    noremap <C-Left> :vertical resize -1<CR>
	    noremap <C-Right> :vertical resize +1<CR> " CTRL-L is already used for redraw.
    endif
else
	nnoremap <C-J> <C-W><C-J>
	nnoremap <C-K> <C-W><C-K>
	nnoremap <C-L> <C-W><C-L>
	nnoremap <C-H> <C-W><C-H>
	set encoding=utf-8
endif

"-----------------------------------------------------------------------------
" tagbar
"-----------------------------------------------------------------------------
"let g:tagbar_ctags_bin = '/usr/local/bin/ctags'

"-----------------------------------------------------------------------------
"                           MultipleSearch Settings
"-----------------------------------------------------------------------------
let g:MultipleSearchMaxColors = 6
let g:MultipleSearchColorSequence = "Red,Yellow,Magenta,White,Blue"
let g:MultipleSearchTextColorSequence = "white,black,white,black,white,black"


" search current file's directory first (./tags), current directory second (tags), 
" then files listed in other directories.
set tags=./tags,tags,../tags,../../tags


"-----------------------------------------------------------------------------
" Show Marks
"-----------------------------------------------------------------------------
" Disabled until I find the cause of that annoying error message.
let showmarks_enable=0
let g:showmarks_include="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.'`^<>[]{}()\""
let g:showmarks_ignore_type="hmpqr"
let g:showmarks_textlower="\t>"
let g:showmarks_textupper="\t+"
let g:showmarks_textother="\t-"

"-----------------------------------------------------------------------------
" Error Marker
"-----------------------------------------------------------------------------
let loaded_errormarker=1 " disable plugin
let errormarker_errortext="ER"
let errormarker_warningtext="WA"
let &errorformat="%f:%l: %t%*[^:]:%m," . &errorformat
let &errorformat="%f:%l:%c: %t%*[^:]:%m," . &errorformat
let errormarker_warningtypes = "wW"

"-----------------------------------------------------------------------------
"                              clang-complete
"-----------------------------------------------------------------------------
"let g:clang_user_options = '-std=c++17'

"-----------------------------------------------------------------------------
"                          Vim-Session Plugin Settings
"-----------------------------------------------------------------------------
let g:session_autosave = 'no'
let g:session_autoload = 1
let g:session_command_aliases = 1
set sessionoptions-=options
set sessionoptions+=resize

"-----------------------------------------------------------------------------
"								Syntastic Settings
"-----------------------------------------------------------------------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_cpp_compiler_options = '-std=c++17\ -isystem /opt/gcc-multilib-8.2.0/include/c++/8.2.0/'

"-----------------------------------------------------------------------------
"                        Map Markdown
"-----------------------------------------------------------------------------
nnoremap <leader>md :%!c:/bin/Markdown.pl --html4tags<CR>

"-----------------------------------------------------------------------------
" Word Processor mode.  Invoke with :WP.
" https://jasonheppler.org/2012/12/05/word-processor-mode-in-vim/
"-----------------------------------------------------------------------------
"func! WordProcessor()
"	" movement changes
"	map j gj
"	map k gk
"	" formatting text
"	setlocal formatoptions=1
"	setlocal noexpandtab
"	setlocal wrap
"	setlocal linebreak
"	" spelling and thesaurus
"	setlocal spell spelllang=en_us
"	set thesaurus+=/home/bgb/.vim/thesaurus/mthesaur.txt
"	" complete+=s makes autocompletion search the thesaurus
"	set complete+=s
"endfu
"com! WP call WordProcessor()


"-----------------------------------------------------------------------------
" setup vim-plug plugin manager
"-----------------------------------------------------------------------------
" Specify a directory for plugins 
call plug#begin('~/.vim/plugged')
"Plug 'valid git URL'	" Any valid git URL is allowed for plugin
"Plug 'foo/bar'			" Shorthand notation for plugin
Plug 'pearofducks/ansible-vim'	" install ansible-vim for syntax highlighting
Plug 'neomake/neomake'			" install neomake for linting
" Initialize plugin system
call plug#end()


"-----------------------------------------------------------------------------
"                     Load all help files in vimfiles/doc. 
"-----------------------------------------------------------------------------
"Helptags


" Prevent autocmd, shell, and write commands in .vimrc in 
" current directory (not $HOME/.vimrc).
" Help says put this at the end of ~/.vimrc.
set secure


"-----------------------------------------------------------------------------
" Setup vim-plug plugin manager.
"-----------------------------------------------------------------------------
" Specify a directory for plugins 
call plug#begin('~/.vim/plugged')
" Any valid git URL is allowed for plugin
Plug 'pearofducks/ansible-vim'
" Shorthand notation for plugin
Plug 'neomake/neomake'
" Initialize plugin system
call plug#end()

" When writing a buffer (no delay).
"call neomake#configure#automake('w')
" When writing a buffer (no delay), and on normal mode changes (after 750ms).
"call neomake#configure#automake('nw', 750)
" When reading a buffer (after 1s), and when writing (no delay).
call neomake#configure#automake('rw', 1000)
" Full config: when writing or reading a buffer, and on changes in insert and
" normal mode (after 1s; no delay when writing).
"call neomake#configure#automake('nrwi', 500)

" ----------------------------------- eof -----------------------------------
