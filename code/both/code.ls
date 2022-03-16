dayjs.locale \vi

os =
	uniqIdVal: 0

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
		res * " "

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
		for k, val of target
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
				@attrs = void
				@dom = void
				@old$$ = void

	clamp: (num, min, max) ->
		unless max?
			[min, max] = [0, min]
		if num < min => min
		else if num > max => max
		else num

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

	rand: (min = 0, max = 1) ->
		if min > max
			[min, max] = [max, min]
		Math.floor min + Math.random! * (max - min + 1)

	uuid: ->
		"_#{@uniqId!toString 36}#{Date.now!toString 36}#{@rand 9e15 .toString 36}"

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

	fetch: (url, opts, type = \text) ->
		if typeof opts is \string
			[opts, type] = [, opts]
		fetch url, opts .then (.[type]!)

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

/* comp */
/* code */

m.mount appEl, App
