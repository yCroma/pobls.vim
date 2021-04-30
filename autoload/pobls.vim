let g:pobls_show_unlisted_buffers = get(g:, 'pobls_show_unlisted_buffers', 0)
let g:pobls_ignore_pattern = get(g:, 'pobls_ignore_pattern', [])

function! pobls#start() abort " Run pobls.vim
	" s:list_bufnr needs to be script scope as it is used for popup generation
	let s:list_bufnr = pobls#set_list_bufnr()
	" bufname is generated from bufnr
	" so we need to filter it here
	call s:filter_list_bufnr()
	let s:list_bufname = pobls#set_list_bufname()
	" bufnr is already filtered
	" bufname will be filtered now
	call s:render_list_bufname()
	call pobls#display_popup()
endfunction

function! pobls#set_list_bufnr() abort " Switch functions by value of unlisted_buffers
	" Make it local scope to avoid referring to the same memory
	if (g:pobls_show_unlisted_buffers == 0)
		let l:list_bufnr = pobls#set_list_bufnr_listed()
	else
		let l:list_bufnr = pobls#set_list_bufnr_unlisted()
	endif
	return l:list_bufnr
endfunction

function! pobls#set_list_bufnr_listed() abort 
	" Set the listed buffers
	return filter(range(1,bufnr('$')),'buflisted(v:val)	&& "quickfix" !=? getbufvar(v:val, "&buftype") ')
endfunction

function! pobls#set_list_bufnr_unlisted() abort 
	" Set the existed buffers
	return filter(range(1,bufnr('$')),'bufexists(v:val)	&& "quickfix" !=? getbufvar(v:val, "&buftype") ')
endfunction

function! pobls#set_list_bufname() abort " Get bufname from bufnr
	let l:list_bufnr = s:list_bufnr
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

function! s:filter_list_bufnr() abort
	let l:ignore_pattern = '\v'.join(g:pobls_ignore_pattern, '|')
	let s:list_bufnr = filter(s:list_bufnr, 'bufname(v:val) !~# l:ignore_pattern')
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
	elseif a:key is# 'd'
		return s:WipeOutBuffer(a:winid, 'bw', a:ctx.Bufnr[a:ctx.idx])
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

function s:WipeOutBuffer(winid, open, Bufnr) abort
	call popup_close(a:winid)
	execute a:open a:Bufnr
	" Restart to update the script variables
	call pobls#start()
	return 1
endfunction
