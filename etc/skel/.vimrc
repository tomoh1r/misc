" vim: ft=vim:

let s:dotmisc = expand('~/Documents/misc/dotfiles/misc/vim/')

" 基本的に bash のスクリプトを操作するので
let g:is_bash = 1

if has('mac')
    let s:hb_opt = expand('~/.homebrew/opt/')
    let $PERL_DLL = s:hb_opt . 'perl/lib/5.20.1/darwin-thread-multi-2level/CORE/libperl.dylib'
    let $PYTHON_DLL = s:hb_opt . 'python/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib'
    let $PYTHON3_DLL = s:hb_opt . 'python3/Frameworks/Python.framework/Versions/3.4/lib/libpython3.4.dylib'
    let $RUBY_DLL = s:hb_opt . 'ruby/lib/libruby.2.2.0.dylib'
    let $LUA_DLL = s:hb_opt . 'lua/lib/liblua.5.2.3.dylib'
endif

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

if has('gui_running')
    se showtabline=2 " タブを常に表示
    se nonumber      " 行番号非表示

    se guifont=Migu\ 2M\ 11
    se clipboard=unnamedplus
    se guioptions-=T

    if has('win32')
        se guifont=Myrica_M:h12:cSHIFTJIS
        se clipboard=unnamed
    elseif has('gui_macvim')
        se backspace=indent,eol,start
        se antialias
        se guifont=Migu\ 2M:h12
        se ambiwidth=double
        se clipboard=unnamed
        se columns=205 lines=55
        se imdisable
    endif
endif

" user settings

"let g:flake8_cmd="/home/tomo/Documents/misc/bin/flake8"
"colo default
