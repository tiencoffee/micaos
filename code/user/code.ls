send = yes

let
	postMessage = top~postMessage
	Promise = window.Promise
	randomUUID = crypto~randomUUID
	isArray = Array.isArray

	tid = "/* tid */"
	resolvers = {}

	send := (type, name, args) ~>
		new Promise (resolve, reject) !~>
			mid = randomUUID!
			resolvers[mid] =
				resolve: resolve
				reject: reject
			postMessage [type, name, tid, mid, args] \*

	addEventListener \message (event) !~>
		{data} = event
		if isArray data
			[type, mid, result, isErr] = data
			switch type
			| \umu
				if resolver = resolvers[mid]
					resolver[isErr and \reject or \resolve] result
					delete resolvers[mid]

	data = await send \umu \$initTask
	tid = data.tid
	for let name in data.publicMethodNames
		unless name.0 is \$
			os[name] = (...args) ->
				send \umu name, args
	os.args = data.args

	os <<<
		isLockContextMenu: no
		contextMenuList: void
		contextMenuOncloses: []

		showContextMenu: (event, ...items) !->
			if event instanceof MouseEvent and event.type is \contextmenu and event.isTrusted
				unless @isLockContextMenu
					if typeof items[* - 1] is \function
						onclose = items.pop!
						@contextMenuOncloses.unshift onclose
					@[]contextMenuList.push items

		closeContextMenu: !->
			for onclose in @contextMenuOncloses
				onclose!
			@isLockContextMenu = no
			@contextMenuList = void
			@contextMenuOncloses = []

	document.body.addEventListener \mousedown (event) !~>
		await send \umu \$mousedownTask [event.x, event.y, event.button]

	document.body.addEventListener \contextmenu (event) !~>
		event.preventDefault!
		[items, cbs] = os.createContextMenuItems os.contextMenuList, yes
		if items.length
			cbId = await send \umu \$contextMenuTask [event.x, event.y, items]
			cbs[cbId]?!
		os.closeContextMenu!
		m.redraw!

	os.bind os

let os, send = void
	/* code */

	m.mount appEl, App
