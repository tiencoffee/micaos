class Task
	(app, env, cid, parent, resolve, code, styl) ->
		for k, val of staticMethods
			@[k] = val
		for k, val of getPublicMethods yes
			@[k] = val
		for k, val of getPrivateMethods yes
			@[k] = val
		@bind @
		@app = app
		@env = {} <<< env
		@args = {} <<< env.args
		@evts = Array.from env.evts || []
		@resolve = resolve
		@cid = cid ? crypto.randomUUID!
		@parent = parent
		@pid = os.uniqId!
		@tid = crypto.randomUUID!
		@title = env.title ? app.title ? app.name
		@width = @clamp env.width || app.width || 800 @minWidth, @maxWidth
		@height = @clamp env.height || app.height || 600 @minHeight, @maxHeight
		x = env.x ? app.x
		@x =
			if isFinite x => @clamp x, os.desktopWidth - @width
			else Math.floor (os.desktopWidth - @width) / 2
		y = env.y ? app.y
		@y =
			if isFinite y => @clamp y, os.desktopHeight - @height
			else Math.floor (os.desktopHeight - @height) / 2
		@minimizable = env.minimizable ? app.minimizable ? yes
		@maximizable = env.maximizable ? app.maximizable ? yes
		@resizable = env.resizable ? app.resizable ? yes
		@movable = env.movable ? app.movable ? yes
		@focusable = env.focusable ? app.focusable ? yes
		@header = env.header ? app.header ? yes
		@skipTaskbar = env.skipTaskbar ? app.skipTaskbar ? no
		@acceptFirstMouse = env.acceptFirstMouse ? app.acceptFirstMouse ? yes
		@transparent = env.transparent ? app.transparent ? no
		@minimized = env.minimized ? app.minimized ? no
		@maximized = env.maximized ? app.maximized ? no
		@admin = env.admin ? app.admin ? no
		@moving = no
		@resizing = void
		@firstMinimize = @minimized
		@didMaximize = no
		@minimizeAnim = void
		@postMessage = void
		code = userCode.replace /(^\t+)?\/\* (.+?) \*\//gm (, tab, name) ~>
			val = switch name
				| \code => code
				| \tid => @tid
			val = @indent val, tab.length if tab
			val
		styl = userStyl.replace /(^\t+)?\/\* (.+?) \*\//gm (, tab, name) ~>
			val = switch name
				| \styl => styl
			val = @indent val, tab.length if tab
			val
		code = livescript.compile code
		styl = stylus.render styl, compress: yes
		@html = userHtml.replace /\/\* (.+?) \*\//gm (, name) ~>
			switch name
				| \styl => styl
				| \code => code

	minWidth:~ ->
		@clamp (@env.minWidth or @app.minWidth or 200), 200 os.desktopWidth

	maxWidth:~ ->
		@clamp (@env.maxWidth or @app.maxWidth or os.desktopWidth), @minWidth, os.desktopWidth

	minHeight:~ ->
		@clamp (@env.minHeight or @app.minHeight or 80), 80 os.desktopHeight

	maxHeight:~ ->
		@clamp (@env.maxHeight or @app.maxHeight or os.desktopHeight), @minHeight, os.desktopHeight

	oncreate: (vnode) !->
		@dom = vnode.dom
		@iframe = @dom.querySelector \iframe
		@iframe.sandbox = """
			allow-downloads
			allow-forms
			allow-pointer-lock
			allow-popups
			allow-presentation
			allow-scripts
		"""
		@iframe.srcdoc = @html
		delete @html
		@updateRectDom!
		if @minimized
			@updateMinimizeDom!

	minimize: (val) ->
		val ?= not @minimized
		if @minimizable
			if val isnt @minimized
				@minimized = val
				@firstMinimize = no
				@updateMinimizeDom!
				m.redraw!
				return yes
		no

	maximize: (val) ->
		val ?= not @maximized
		if @maximizable
			if val isnt @maximized
				@maximized = val
				@didMaximize = yes
				m.redraw!
				return yes
		no

	close: (val) ->
		index = os.tasks.indexOf @
		if index >= 0
			os.tasks.splice index, 1
			@resolve val
			m.redraw!

	updateMinimizeDom: !->
		if @minimized
			if el = document.querySelector ".App__taskbarTask--#@pid"
				rect = el.getBoundingClientRect!
				keyframes = @style do
					left: rect.x
					top: rect.y
					width: rect.width
					height: rect.height
				@minimizeAnim = @dom.animate keyframes,
					duration: 400
					easing: "cubic-bezier(.22,1,.36,1)"
					fill: \forwards
		else
			if @minimizeAnim
				@minimizeAnim.reverse!
				@minimizeAnim = void
			keyframes = @style do
				if @maximized
					left: 0
					top: 0
					width: \100%
					height: \100%
				else
					left: @x
					top: @y
					width: @width
					height: @height
			@dom.animate keyframes,
				duration: 400
				easing: "cubic-bezier(.22,1,.36,1)"

	updateXYDom: !->
		@dom.style.left = @x + \px
		@dom.style.top = @y + \px

	updateSizeDom: !->
		@dom.style.width = @width + \px
		@dom.style.height = @height + \px

	updateRectDom: !->
		@updateXYDom!
		@updateSizeDom!

	onpointerdownTitle: (event) !->
		if event.button is 0
			event.target.setPointerCapture event.pointerId
			@moving = yes

	onpointermoveTitle: (event) !->
		event.redraw = no
		if @moving
			if @maximized
				@x = Math.floor @clamp event.x - @width / 2 os.desktopWidth - @width
				@y = 0
				@maximize no
			@x += event.movementX
			@y += event.movementY
			@updateXYDom!

	onlostpointercaptureTitle: (event) !->
		if @moving
			@moving = no
			{x, y} = event
			if x <= 0 or x >= os.desktopWidth - 1
				@y = 0
				@width = Math.floor os.desktopWidth / 2
				@height = os.desktopHeight
				if x <= 0
					@x = 0
				else
					@x = os.desktopWidth - @width
			else if y <= 0
				@maximize yes
			@x = @clamp @x, os.desktopWidth - @width
			@y = @clamp @y, os.desktopHeight - @height
			@updateRectDom!

	onclickTitle: (event) !->
		unless event.detail % 2
			@maximize!

	onpointerdownResizer: (event) !->
		if event.button is 0
			event.target.setPointerCapture event.pointerId
			dx = +event.target.dataset.x
			dy = +event.target.dataset.y
			@resizing =
				dx: dx
				dy: dy
				mx: 0
				my: 0
				old:
					x: @x
					y: @y
					width: @width
					height: @height
				bound:
					x2: if dx < 0 => @x + @width - @minWidth
					x1: if dx < 0 => Math.max 0 @x + @width - @maxWidth
					maxWidth: Math.min @maxWidth,
						if dx < 0 => @x + @width
						else if dx > 0 => os.desktopWidth - @x
					y2: if dy < 0 => @y + @height - @minHeight
					y1: if dy < 0 => Math.max 0 @y + @height - @maxHeight
					maxHeight: Math.min @maxHeight,
						if dy < 0 => @y + @height
						else if dy > 0 => os.desktopHeight - @y

	onpointermoveResizer: (event) !->
		event.redraw = no
		if @resizing
			{dx, dy, mx, my, old, bound} = @resizing
			if dx
				mx += event.movementX
				if dx < 0
					@x = @clamp old.x + mx, bound.x1, bound.x2
				@width = @clamp old.width + mx * dx, @minWidth, bound.maxWidth
				@resizing.mx = mx
			if dy
				my += event.movementY
				if dy < 0
					@y = @clamp old.y + my, bound.y1, bound.y2
				@height = @clamp old.height + my * dy, @minHeight, bound.maxHeight
				@resizing.my = my
			@updateRectDom!

	onlostpointercaptureResizer: (event) !->
		if @resizing
			@resizing = void

	onbeforeremove: (vnode) ->
		@dom.animate do
			* transform: "scale(.9)"
				opacity: 0
			* duration: 400
				easing: "cubic-bezier(.22,1,.36,1)"
		.finished

	view: ->
		m \.Task,
			class: @class do
				"Task--moving": @moving
				"Task--firstMinimize": @firstMinimize
				"Task--didMaximize": @didMaximize
				"Task--minimized": @minimized
				"Task--maximized": @maximized
				"Task--transparent": @transparent
			m \.Task__content,
				if @header
					m \.Task__header,
						m Popover,
							placement: \bottom-start
							content: (close) ~>
								m Menu,
									basic: yes
									items:
										* text: "Thu nhỏ"
											icon: \minus
											shown: @minimizable
											onclick: !~>
												close!
												@minimize!
										* text: "Phóng to"
											icon: \plus
											shown: @maximizable
											onclick: !~>
												close!
												@maximize!
										* text: "Đóng"
											icon: \close
											color: \red
											onclick: !~>
												close!
												m.redraw.sync!
												@close!
							m Button,
								class: "Task__icon"
								basic: yes
								small: yes
								icon: @app.icon
						m \.Task__title,
							onpointerdown: @onpointerdownTitle
							onpointermove: @onpointermoveTitle
							onlostpointercapture: @onlostpointercaptureTitle
							onclick: @onclickTitle
							@title
						m \.Task__buttons,
							m Button,
								class: "Task__button"
								basic: yes
								small: yes
								icon: \minus
								onclick: !~>
									@minimize!
							m Button,
								class: "Task__button"
								basic: yes
								small: yes
								icon: \plus
								onclick: !~>
									@maximize!
							m Button,
								class: "Task__button"
								basic: yes
								small: yes
								color: \red
								icon: \close
								onclick: !~>
									@close!
				m \.Task__body,
					m \iframe.Task__iframe
				if @resizable and not @maximized and not @minimized
					@@resizers.map (resizer) ~>
						m \.Task__resizer,
							"data-x": resizer.0
							"data-y": resizer.1
							onpointerdown: @onpointerdownResizer
							onpointermove: @onpointermoveResizer
							onlostpointercapture: @onlostpointercaptureResizer

	@resizers = [[0 -1] [1 0] [0 1] [-1 0] [-1 -1] [1 -1] [1 1] [-1 1]]
