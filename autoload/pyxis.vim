" A simple Vim script that makes for quick finding and opening files
" Maintainer: Gustaf Sjöberg <gs@pipsq.com>
" Last Change: 2012 Jan 29

if exists("g:loaded_pyxis")
    finish
endif
let g:loaded_pyxis = 1

if !exists("g:pyxis_ignore")
    let g:pyxis_ignore = "*.jpeg,*.jpg,*.pyo,*.pyc,.DS_Store,*.png,*.bmp,
                         \*.gif,*~,*.o,*.class,*.ai,*.plist,*.swp,*.mp3,*.db,
                         \*.beam,*.pdf,*.swf,*.flv,*.mpeg,*.mp4,*.zip,*.tar,
                         \*.tgz,*.tar.gz,*.wmv,*git*,*/.*/*,*.o,*.hi"
endif

let s:_prompt = '> '

function! pyxis#InitUI()
    let s:_completeopt = &completeopt
    let s:_splitbelow = &splitbelow
    let s:_paste = &paste
    let s:_ttimeoutlen = &ttimeoutlen

    set nosplitbelow " Always show the completion-window above current

    exec '1split [Start typing the name of a file ...]'
    
    setlocal nobuflisted " Do not show in buf list
    setlocal nonumber " Do not display line numbers
    setlocal noswapfile " Do not use a swapfile for the buffer
    setlocal buftype=nofile " The buffer is not related to any file
    setlocal bufhidden=delete " The buffer dies with the window
    setlocal noshowcmd " Be restrictive with what to show in statusbar
    setlocal nowrap " Do not wrap long lines
    setlocal winfixheight " Keep height when other windows are opened
    setlocal textwidth=0 " No maximum text width
    setlocal nopaste " Paste mode interferes
    setlocal statusline=%f

    set ttimeoutlen=0 " Make <Esc> snappy while preserving arrow keys
    set completeopt=menuone " Use popup with only one match
    set completefunc=pyxis#CompleteFunc

    let s:bufno = bufnr('%')

    inoremap <silent> <buffer> <Tab> <Down>
    inoremap <silent> <buffer> <S-Tab> <Up>

    inoremap <silent> <buffer> <CR> <C-Y><C-R>=<SID>OpenFile()<CR>
    inoremap <silent> <buffer> <C-Y> <C-Y><C-R>=<SID>OpenFile()<CR>
    inoremap <silent> <buffer> <C-V> <C-Y><C-R>=<SID>OpenFile('vsplit')<CR>
    inoremap <silent> <buffer> <C-H> <C-Y><C-R>=<SID>OpenFile('split')<CR>
    inoremap <silent> <buffer> <C-T> <C-Y><C-R>=<SID>OpenFile('tabnew')<CR>

    inoremap <silent> <buffer> <C-C> <C-E><C-R>=<SID>Reset()<CR>

    augroup Pyxis
        autocmd!
        autocmd CursorMovedI <buffer> call s:CursorMoved()
        autocmd InsertLeave <buffer> call s:Reset()
    augroup end

    " the prompt seems to fix a problem where `CursorMovedI` sometimes is not
    " triggered if the pum is visible. found this fix while browsing the
    " fuzzyfinder source code.
    call setline(1, s:_prompt)
    call feedkeys("A", 'n')
endfunction

function! pyxis#CompleteFunc(start, base)
    if a:start == 1
        return 0
    endif
    return s:Match(a:base[len(s:_prompt):])
endfunction

let s:_onlyfiles = 1
function! pyxis#ToggleMode()
    let s:_onlyfiles = (!s:_onlyfiles)
    call feedkeys("\<C-X>\<C-U>\<C-P>\<Down>", 'n')
endfunction

function! s:Reset()
    stopinsert!
    exec 'bdelete! '.s:bufno
    let &completeopt=s:_completeopt
    let &ttimeoutlen=s:_ttimeoutlen
    if s:_paste
        set paste
    endif
    if s:_splitbelow
        set splitbelow
    endif
    let s:last_col = 0
    return ''
endfunction

let s:last_col = 0
function! s:CursorMoved()
    let cur_col = col(".")
    if len(getline(".")) <= len(s:_prompt)
        call setline('.', s:_prompt)
        call feedkeys("\<END>", 'n')
    endif
    if cur_col != s:last_col
        call feedkeys("\<C-X>\<C-U>\<C-P>\<Down>", 'n')
    endif
    let s:last_col = cur_col
    return ''
endfunction

function! s:OpenFile(...)
    let filename = getline('.')

    " strip the prompt from the current line. this can prevent a valid file
    " from being openened if it was selected using the pum and has a name that
    " is equal to the prompt.
    if filename[:len(s:_prompt) - 1] ==# s:_prompt
        let filename = filename[len(s:_prompt):]
    endif

    call s:Reset()
    if !empty(filename) && filename != s:_prompt
        exec ":silent ".(a:0 == 1 ? a:1 : "edit")." ".fnameescape(filename)
    endif
endfunction

function! s:BuildCacheFind()
    let ignore = split(g:pyxis_ignore, ',')
    let input = map(ignore, '" -not -iname \x27".v:val."\x27"')
    call add(input, " -not -path './.\*'")
    return split(system('find -L . -type f '.join(input, ' ')), '\n')
endfunction

function! s:BuildCacheNative()
    let wildignore = &wildignore
    let &wildignore = g:pyxis_ignore
    let results = globpath('.', "**/*")
    let &wildignore = wildignore
    return filter(split(results, '\n'), '!isdirectory(v:val)')
endfunction

let s:path = ''
let s:cache = []
function! pyxis#UpdateCache(force)
    let path = getcwd()
    if a:force || empty(s:cache) || path != s:path
        echo "Updating cache ..."
        let s:cache = map(s:BuildCacheNative(), 'v:val[2:]')
        let s:path = path
        redraw | echo "Cache updated!"
    endif
    return ""
endfunction

function! s:Match(needle)
    call pyxis#UpdateCache(0)
    let n = escape(a:needle, '/\.~^$')
    let n = substitute(n, '\(\\\/\|_\)', '.*\1.*', 'g')
    if s:_onlyfiles
        let n = n.'[^/]*$'
    endif
    return filter(s:cache[:], 'v:val =~? n')[:1500]
endfunction
