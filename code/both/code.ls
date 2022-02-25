os =
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
		->
			old = void
			{} <<< props <<<
				oninit: (vnode) !->
					os.bind @
					@attrs = vnode.attrs
					@attrs.children ?= vnode.children
					props.oninit?call @
					props.onbeforeupdate?call @, old, yes
				oncreate: (vnode) !->
					@dom = vnode.dom
					props.oncreate?call @
					props.onupdate?call @, old, yes
					old := {@dom}
				onbeforeupdate: (vnode) ->
					old.attrs = @attrs
					@attrs = vnode.attrs
					@attrs.children ?= vnode.children
					props.onbeforeupdate?call @, old, no
				onupdate: (vnode) !->
					old.dom = @dom
					@dom = vnode.dom
					props.onupdate?call @, old, no
				onremove: !->
					props.onremove?call @
					@dom = void
					old := void

	clamp: (num, min, max) ->
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

/* comp */
/* code */

m.mount appEl, App
