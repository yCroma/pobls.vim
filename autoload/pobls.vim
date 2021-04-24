let g:pobls_show_unlisted_buffers = get(g:, 'pobls_show_unlisted_buffers', 0)

function! pobls#start() abort " Run pobls.vim
	" Declare variables in script scope
	let s:list_bufnr = pobls#set_list_bufnr()
	let s:list_bufname = pobls#set_list_bufname()
	" Process data in script scope
	call s:render_list_bufname()
	" At this point, the data for the pop-up is complete
	" if you want to filter the data, you can do it after this line
	call pobls#display_popup()
endfunction

function! pobls#set_list_bufnr() abort " Local scope do not refer to the same memory
	" Set a list of bufnr to l:list_bufnr
	if (g:pobls_show_unlisted_buffers == 0)
		let l:list_bufnr = pobls#set_list_bufnr_listed()
	else
		let l:list_bufnr = pobls#set_list_bufnr_unlisted()
	endif
	return l:list_bufnr
endfunction

function! pobls#set_list_bufnr_listed() abort " Required for pobls#set_list_bufnr
	" Set the listed buffers
	return filter(range(1,bufnr('$')),'buflisted(v:val)	&& "quickfix" !=? getbufvar(v:val, "&buftype") ')
endfunction

function! pobls#set_list_bufnr_unlisted() abort " Required for pobls#set_list_bufnr
	" Set the existed buffers
	return filter(range(1,bufnr('$')),'bufexists(v:val)	&& "quickfix" !=? getbufvar(v:val, "&buftype") ')
endfunction

function! pobls#set_list_bufname() abort " To make a list for use in a popup
	let l:list_bufnr = pobls#set_list_bufnr()
	let l:list_bufname = map(l:list_bufnr, 'bufname(v:val)')
	return l:list_bufname
endfunction

function! s:render_list_bufname() abort 
	" Convert unnamed buffer to 'No name'
	let s:list_bufname = map( s:list_bufname, 's:ModifyEmptyString(v:val)')
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

function! pobls#display_popup() abort
	" call popup_menu
	let ctx = {
	\	'idx': 0,
	\	'Bufnr': s:list_bufnr,
	\	}

	call popup_menu(
	\ s:list_bufname, 
	\	#{
	\		filter: function('s:MyMenuFilter', [ctx])
	\	})
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
		return s:OpenSplit(a:winid, 'vsp', bufname(a:ctx.Bufnr[a:ctx.idx]))
	elseif a:key is# 's'
		return s:OpenSplit(a:winid, 'sp', bufname(a:ctx.Bufnr[a:ctx.idx]))
	endif
	return popup_filter_menu(a:winid, a:key)
endfunction

function s:OpenBuffer(winid, open, Bufnr) abort " Used to open a buffer
	call popup_close(a:winid)
	execute a:open a:Bufnr
	return 1
endfunction

function s:OpenSplit(winid, open, Bufname) abort
	call popup_close(a:winid)
	execute a:open a:Bufname
	return 1
endfunction
