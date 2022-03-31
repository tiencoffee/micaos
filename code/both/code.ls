dayjs.locale \vi

os =
	uniqIdVal: 0
	importPaths: {}

	cssUnitless:
		animationIterationCount: yes
		aspectRatio: yes
		borderImageOutset: yes
		borderImageSlice: yes
		borderImageWidth: yes
		boxFlex: yes
		boxFlexGroup: yes
		boxOrdinalGroup: yes
		columnCount: yes
		columns: yes
		flex: yes
		flexGrow: yes
		flexPositive: yes
		flexShrink: yes
		flexNegative: yes
		flexOrder: yes
		gridArea: yes
		gridRow: yes
		gridRowEnd: yes
		gridRowSpan: yes
		gridRowStart: yes
		gridColumn: yes
		gridColumnEnd: yes
		gridColumnSpan: yes
		gridColumnStart: yes
		fontWeight: yes
		lineClamp: yes
		lineHeight: yes
		opacity: yes
		order: yes
		orphans: yes
		tabSize: yes
		widows: yes
		zIndex: yes
		zoom: yes
		fillOpacity: yes
		floodOpacity: yes
		stopOpacity: yes
		strokeDasharray: yes
		strokeDashoffset: yes
		strokeMiterlimit: yes
		strokeOpacity: yes
		strokeWidth: yes

	class: (...items) ->
		res = []
		for item in items
			if Array.isArray item
				res.push @class ...item
			else if item instanceof Object
				for k, val of item
					res.push k if val
			else
				res.push item
		res.join " "

	style: (...items) ->
		res = {}
		for item in items
			if Array.isArray item
				item = @style ...item
			if item instanceof Object
				for k, val of item
					res[k] =
						if not @cssUnitless[k] and +val
							val + \px
						else val
		res

	bind: (target) ->
		for k of target
			unless target.__lookupGetter__ k
				val = target[k]
				if typeof val is \function
					target[k] = val.bind target

	comp: (props) ->
		{oninit, oncreate, onbeforeupdate, onupdate, onremove} = props
		{} <<< props <<<
			oninit: (vnode) !->
				@oninit$$ = oninit
				@oncreate$$ = oncreate
				@onbeforeupdate$$ = onbeforeupdate
				@onupdate$$ = onupdate
				@onremove$$ = onremove
				os.bind @
				@attrs = vnode.attrs or {}
				@attrs.children ?= vnode.children
				@old$$ = void
				@oninit$$?!
				@onbeforeupdate$$? @old$$
			oncreate: (vnode) !->
				@dom = vnode.dom
				@oncreate$$?!
				@onupdate$$? @old$$
				@old$$ = {@dom}
			onbeforeupdate: (vnode) ->
				@old$$.attrs = @attrs
				@attrs = vnode.attrs or {}
				@attrs.children ?= vnode.children
				@onbeforeupdate$$? @old$$
			onupdate: (vnode) !->
				@old$$.dom = @dom
				@dom = vnode.dom
				@onupdate$$? @old$$
			onremove: !->
				@onremove$$?!
				@dom = void
				@old$$ = void

	clamp: (num, min, max) ->
		unless max?
			[min, max] = [0, min]
		if num < min => +min
		else if num > max => +max
		else +num

	addStartStr: (str, strStart) ->
		str += ""
		if str.startsWith strStart => str
		else strStart + str

	addEndStr: (str, strEnd) ->
		str += ""
		if str.endsWith strEnd => str
		else str + strEnd

	castArr: (arr) ->
		if Array.isArray arr => arr
		else if arr? => [arr]
		else []

	castNewArr: (arr) ->
		if Array.isArray arr => [...arr]
		else if arr? => [arr]
		else []

	castFuncVal: (func, thisArg, ...args) ->
		if typeof func is \function
			func.apply thisArg, args
		else func

	uniqId: ->
		++@uniqIdVal

	uniqArr: (arr) ->
		[...new Set arr]

	unionArr: (arr, arr2) ->
		arr = new Set arr
		for val in arr2
			arr.add val
		[...arr]

	diffArr: (arr, arr2) ->
		arr = new Set arr
		for val in arr2
			if arr.has val
				arr.delete val
		[...arr]

	xorArr: (arr, arr2) ->
		arr = new Set arr
		new Set arr2 .forEach (val) !~>
			arr[arr.has val and \delete or \add] val
		[...arr]

	rand: (min = 0, max = 1) ->
		if min > max
			[min, max] = [max, min]
		Math.floor min + Math.random! * (max - min + 1)

	indent: (text, lv) ->
		text.replace /^(?=.)/gm "\t"repeat lv

	createPopper: (ref, popper, opts = {}) ->
		Popper.createPopper ref, popper,
			placement: opts.placement or \auto
			modifiers:
				* name: \offset
					options:
						offset: opts.offset
				* name: \preventOverflow
					options:
						padding: opts.padding
						tether: opts.tether
						tetherOffset: opts.tetherOffset
				* name: \flip
					options:
						fallbackPlacements: opts.flips
						allowedAutoPlacements: opts.allowedFlips

	createUndoable: (items, isInput, duplicate, maxLength) ->
		items = @castArr items
		items.push "" if isInput
		items: items
		index: items.length - 1
		isInput: isInput
		duplicate: duplicate
		maxLength: maxLength or Infinity
		add: (item) !->
			if @canRedo and not isInput
				@items.splice @index + 1
			lastItem = @items[* - (isInput and 2 or 1)]
			if @duplicate or (isInput and item isnt @items[* - 2]) or (not isInput and item isnt @items[* - 1])
				if isInput
					@items[* - 1] = item
					@items.push ""
				else
					@items.push item
			@index = @items.length - 1
		undo: ->
			if @canUndo
				@items[--@index]
		redo: ->
			if @canRedo
				@items[++@index]
		canUndo:~ ->
			@index > 0
		canRedo:~ ->
			@index < @items.length - 1
		item:~ ->
			@items[@index]
		prev:~ ->
			@items[@index - 1]
		next:~ ->
			@items[@index + 1]

	fetch: (url, opts, type = \text) ->
		if typeof opts is \string
			[opts, type] = [, opts]
		res = await fetch url, opts
		if res.ok
			res[type]!
		else
			throw Error "#{res.statusText} '#{res.url}'"

	splitPath: (path) ->
		path .= trim!
		if path.0 is \/
			root = \/
			path .= substring 1
		else
			root = ""
		nodes = path.split /\s*\/+\s*/ .filter Boolean
		[nodes, root]

	normPath: (path, isKeepDot) ->
		[nodes, root] = @splitPath path
		if isKeepDot
			res = nodes
		else
			res = []
			for node in nodes
				switch node
				| \. =>
				| \.. => res.pop!
				else res.push node
		root + res.join \/

	resolvePath: (...paths) ->
		for path, i in paths by -1
			if path.trimStart!0 is \/
				break
		paths .= slice i
		@joinPath ...paths

	joinPath: (...paths) ->
		path = paths.join \/
		@normPath path

	dirPath: (path) ->
		[nodes, root] = @splitPath path
		root + nodes.slice 0 -1 .join \/

	filePath: (path) ->
		[nodes] = @splitPath path
		filename = nodes.at -1

	basePath: (path) ->
		filename = @filePath path
		/^(.*?)(?:\.[^.]*)?$/exec filename .1

	extPath: (path, isKeepDot) ->
		filename = @filePath path
		ext = /^.*?((?:\.[^.]*)?)$/exec filename .1
		unless isKeepDot
			ext .= replace \. ""
		ext

	import: (...paths) !->
		code = ""
		styl = ""
		for path in paths
			unless @importPaths[path]
				if /^(?:(\w+):)?(.+?)(?:#(\w+))?$/exec path
					[, cdn, name, type] = that
					@importPaths[path] = yes
					if not cdn and name.0 not in [\. \/]
						cdn = \npm
					unless type
						if /(?<=\.)[a-zA-Z\d\-]+(?=$|\?)/exec name
							type = that.0
					type = (type or \js)toLowerCase!
					text = switch cdn
						| \npm \gh
							await @fetch "https://cdn.jsdelivr.net/#cdn/#name"
						| \https \http
							await @fetch cdn + name
						else
							await @readFile name
					text += \\n
					switch type
					| \js
						code += text
					| \css
						styl += text
				else
					throw Error "Định dạng import không đúng: '#path'"
		if code
			await window.eval code
		else if styl
			el = document.createElement \style
			el.textContent = styl
			document.head.appendChild el

	createContextMenuItems: (list = [], isExtractOnclick) ->
		newItems = []
		tags = {}
		onclicks = []
		callTags = (items) !~>
			items = @castArr items
			for item in items
				if item
					if item.tags
						for tag in item.tags
							tags[tag] ?= []
							tags[tag]push item
					else if item.submenu
						callTags item.submenu
		callItems = (items) ~>
			items = @castArr items
			newItems = []
			for item in items
				if typeof item is \string
					items2 = tags[item]
				else
					items2 = [item]
				if items2
					for item in items2
						if item
							unless item.hidden or \shown of item and not item.shown
								item = {...item}
								if item.submenu
									item.submenu = callItems item.submenu
								else
									if isExtractOnclick
										if onclick = item.onclick
											item.onclick = onclicks.length
											onclicks.push onclick
								newItems.push item
						else
							item = divider: yes
							newItems.push item
			newItems
		for items, i in list by -1
			if i
				callTags items
			else
				newItems = callItems items
		[newItems, onclicks]

/* comp */
/* code */
