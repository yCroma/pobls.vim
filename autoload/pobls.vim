let g:pobls_show_unlisted_buffers = 0

function! pobls#begin() abort " Run pobls.vim
	let l:List_Bufnr = pobls#add_List_Bufnr()
	let l:List_Buf_Name = pobls#add_List_Buf_Name()
	let ctx = {
	\	'idx': 0,
	\	'Bufnr': List_Bufnr,
	\	}
	call popup_menu(List_Buf_Name, #{
	\	filter: function('s:MyMenuFilter', [ctx])})
endfunction

function! pobls#add_List_Bufnr() abort " Required to get the buffer list
	let l:List_Bufnr = []
	if (g:pobls_show_unlisted_buffers == 0)
		let l:List_Bufnr = pobls#add_List_Bufnr_Listed()
	else
		let l:List_Bufnr = pobls#add_List_Bufnr_Unlisted()
	endif
	return l:List_Bufnr
endfunction

function! pobls#add_List_Bufnr_Listed() abort " Required to generate an array of listed buffers
	return filter(range(1,bufnr('$')),'buflisted(v:val)	&& "quickfix" !=? getbufvar(v:val, "&buftype") ')
endfunction

function! pobls#add_List_Bufnr_Unlisted() abort " Required to generate an array of listed and unlisted buffers
	return filter(range(1,bufnr('$')),'bufexists(v:val)	&& "quickfix" !=? getbufvar(v:val, "&buftype") ')
endfunction

function! pobls#add_List_Buf_Name() abort " To make a list for use in a popup
	let l:List_Bufnr = pobls#add_List_Bufnr()
	let l:List_Buf_Name = map( l:List_Bufnr, 'bufname(v:val)')
	let l:List_Rendered_Buf_Name = map( l:List_Buf_Name, 's:ModifyEmptyString(v:val)')
	return l:List_Rendered_Buf_Name
endfunction


function! s:ModifyEmptyString(string) abort " To convert empty file names
	let l:Buffer_Name = ""
	if a:string == ""
		let l:Buffer_Name = 'No Name'
	else
		let l:Buffer_Name = a:string
	endif
	return l:Buffer_Name
endfunction

function! s:MyMenuFilter(ctx, winid, key) abort " Required for operations within a popup
	if a:key is# 'j'
		if a:ctx.idx < len(a:ctx.Bufnr) - 1
			let a:ctx.idx = a:ctx.idx + 1
		endif
	elseif a:key is# 'k'
		if a:ctx.idx > 1
			let a:ctx.idx = a:ctx.idx - 1
		endif
	elseif a:key is# "\<CR>"
		return s:OpenBuffer(a:winid, 'b', a:ctx.Bufnr[a:ctx.idx])
	elseif a:key is# 'v'
		return s:OpenBuffer(a:winid, 'vsp', bufname(a:ctx.Bufnr[a:ctx.idx]))
	elseif a:key is# 's'
		return s:OpenBuffer(a:winid, 'sp', bufname(a:ctx.Bufnr[a:ctx.idx]))
	endif
	return popup_filter_menu(a:winid, a:key)
endfunction

function s:OpenBuffer(winid, open, Bufnr) abort " Used to open a buffer
	call popup_close(a:winid)
	execute a:open.a:Bufnr
	return 1
endfunction

