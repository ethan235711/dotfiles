" File to add automatic filetype detection and turn on appropriate syntax
" highlighting
if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
    au! BufRead,BufNewFile *.vm  setfiletype velocity
augroup END
