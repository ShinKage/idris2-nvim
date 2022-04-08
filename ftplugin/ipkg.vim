if exists("b:did_ftplugin")
  finish
endif

setlocal comments=:--
setlocal commentstring=--%s
setlocal wildignore+=*.ibc

let b:did_ftplugin = 1
