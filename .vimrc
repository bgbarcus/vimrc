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

if has("unix")
	let g:ycm_confirm_extra_conf = 0					" default = 1
	let g:ycm_min_num_of_chars_for_completion = 3		" default = 2
	let g:ycm_min_num_identifiers_candidate_chars = 0	" default = 0
	let g:ycm_show_diagnostics_ui = 1                   " default = 1
	let g:ycm_enable_diagnostic_highlighting = 0        " default = 1
else
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

	if has("unix")
		set csprg=cscope
	
		" add any database in current directory
		if filereadable("cscope.vim")
	    	cs add cscope.vim
		endif

		"set grepprg=ack
		set grepprg=ag\ --ignore-dir\ builds\ --vimgrep\ $*
        set grepformat=%f:%l:%c:%m
		"let g:ackprg = 'ag --vimgrep' "show all matches on each line
		"let g:ackprg = 'ag --nogroup --nocolor --column'
	else
		"set csprg=C:/bin/cscope.exe
		set csprg=gtags-cscope.exe
	
		" add any database in current directory
		if filereadable("GTAGS")
	    	cs add GTAGS
		endif

		set grepprg=ack.pl\ --noenv\ --ignore-directory=_CHE
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
set tabstop=4
set shiftwidth=4
set cindent
"set cinkeys=
set cinwords=if,else,while,do,for,switch,try,catch
set cinoptions=>s,es,ns,f0,{0,}0,^0,L-1,:0,=s,l1,b0,g0,hs,N-s,t0,is,+s,c1,C1,/0,(0,W4,u0,U1
set noexpandtab
set noautoindent
set smartindent
set smarttab
set copyindent
set preserveindent
set nosplitright
set scrolljump=1
set scrolloff=3
set sidescroll=1
set nowrapscan
set noincsearch
set makeprg=make
set nocursorline
set nocursorcolumn
set undolevels=2048
set noequalalways
set textwidth=0
set winwidth=1
set wildignore=tags,cscope*,*.o,.git,commit.log,diff.txt,session.vim,*.swp
set wildmenu
set nopaste " set paste to turn off all formating for pasting from the clipboard.

set foldenable
set foldmethod=syntax
set foldcolumn=0
set foldlevel=99

colorscheme Mustang

if has("gui")
    set guioptions=egt
	set term=win32

	if has("unix")
		set mouse=vcr
		set guifont=Monospace\ 9
	else
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
	colorscheme koehler
endif

set sessionoptions=curdir,folds,resize,slash,tabpages,winpos,winsize

" Load header file from directory above the .cpp file (:help filename-modifiers).
noremap _hh :new %:p:h/../%:r:r.h
noremap _HH :vnew %:p:h/../%:r:r.h

noremap! <F1> <Esc> "Turn off help key - too close to escape on notebook keyboard.
nnoremap <F2> :!clang-format
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

noremap <C-F7> :1,%!Uncrustify.exe -q -c c:\uncrustify.cfg

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
endif


"-----------------------------------------------------------------------------
" Tag List
"-----------------------------------------------------------------------------
"noremap <C-F10> :TlistOpen<CR>
"noremap <C-F11> :TlistClose<CR>
"noremap <C-F12> :TlistToggle<CR>
"set Tlist_Ctags_Cmd=C:\bin\ctags.exe
"let Tlist_Auto_Open=1 " automatically open taglist on startup
"let Tlist_Close_On_Select=1 " close list after selecting tag
"let Tlist_Use_SingleClick=1 " open tag on single mouse click
"let Tlist_Exit_OnlyWindow=1 " exit vim if taglist is the only windows
"let Tlist_Show_Menu=1 " put tags menu on gvim menu bar


"-----------------------------------------------------------------------------
"                           MultipleSearch Settings
"-----------------------------------------------------------------------------
let g:MultipleSearchMaxColors = 6
let g:MultipleSearchColorSequence = "Red,Yellow,Green,Blue,Magenta,White"
let g:MultipleSearchTextColorSequence = "white,black,white,black,white,black"


" search current file's directory first (./tags), current directory second (tags), 
" then files listed in other directories.
set tags=./tags,tags,../tags,../../tags


" Vim Commander
"noremap <silent> <S-F1> :call VimCommanderToggle()<CR>


"-----------------------------------------------------------------------------
" Show Marks
"-----------------------------------------------------------------------------
" Disabled until I find the cause of that annoying error message.
let showmarks_enable=0
let showmarks_textlower="\t>"
let showmarks_textupper="\t+"
" This is the default list containing all marks.
let showmarks_include="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.'`^<>[]{}()\""


"-----------------------------------------------------------------------------
" Error Marker
"-----------------------------------------------------------------------------
let errormarker_errortext="ER"
let errormarker_warningtext="WA"
let &errorformat="%f:%l: %t%*[^:]:%m," . &errorformat
let &errorformat="%f:%l:%c: %t%*[^:]:%m," . &errorformat
let errormarker_warningtypes = "wW"

"-----------------------------------------------------------------------------
"                              clang-complete
"-----------------------------------------------------------------------------
let g:clang_user_options = '-std=c++11'

"-----------------------------------------------------------------------------
"                          Vim-Session Plugin Settings
"-----------------------------------------------------------------------------
let g:session_autosave = 'no'
let g:session_autoload = 1
let g:session_command_aliases = 1
set sessionoptions-=options
set sessionoptions+=resize


"-----------------------------------------------------------------------------
"                        Map Markdown
"-----------------------------------------------------------------------------
nnoremap <leader>md :%!c:/bin/Markdown.pl --html4tags<CR>


"-----------------------------------------------------------------------------
"                     Load all help files in vimfiles/doc. 
"-----------------------------------------------------------------------------
"Helptags

" ----------------------------------- eof -----------------------------------
