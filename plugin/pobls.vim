if exists('g:loaded_pobls')
	finish
endif

let g:loaded_pobls = 1

let s:save_cpo = &cpo
set cpo&vim

command! Pobls call pobls#start()

let &cpo = s:save_cpo
unlet s:save_cpo
