" vim: ft=vim:

set packpath+=~/.misc/share/vim
let s:dotmisc = expand('~/.misc/etc/vim/')

" 基本的に bash のスクリプトを操作するので
let g:is_bash = 1

" completion は必要に応じて追加
for s:fname in [
\       'bundle',
\       'encodings',
\       'filetypes',
\       'basis'
\       ]
    if exists('s:fpath')
        unlet s:fpath
    endif
    let s:fpath = s:dotmisc . s:fname
    exe 'so ' . s:fpath
endfor

if getftype(expand('~/.vimrc.local')) == 'file'
  so ~/.vimrc.local
endif

if !has('gui_running')
    "colo dracula
    "se background=dark
else
    " Hide toolbar
    se guioptions-=T
    se guioptions-=m
    " Show tab bar always
    se showtabline=2
    " Hide line number
    se nonumber
    " disable visual bell
    se belloff=all
    se visualbell t_vb=

    se guifont=Migu\ 2M\ 11
    se columns=140 lines=46

    se clipboard=unnamedplus
    if has('win32')
        se clipboard=unnamed
        se ambiwidth=double
        se renderoptions=type:directx,renmode:5
    elseif has('gui_macvim')
        se backspace=indent,eol,start
        se clipboard=unnamed
        se ambiwidth=double
        se antialias
        se imdisable
    endif
endif
se mouse=

if has('mac')
    let s:hb_opt = expand('~/.homebrew/opt/')
    let $PERL_DLL = s:hb_opt . 'perl/lib/5.20.1/darwin-thread-multi-2level/CORE/libperl.dylib'
    let $PYTHON_DLL = s:hb_opt . 'python/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib'
    let $PYTHON3_DLL = s:hb_opt . 'python3/Frameworks/Python.framework/Versions/3.4/lib/libpython3.4.dylib'
    let $RUBY_DLL = s:hb_opt . 'ruby/lib/libruby.2.2.0.dylib'
    let $LUA_DLL = s:hb_opt . 'lua/lib/liblua.5.2.3.dylib'
endif

" user settings
"let g:flake8_cmd="/home/tomo/Documents/misc/bin/flake8"
