Popover = os.comp do
	oninit: !->
		@isOpen = no
		@popper = void
		@el = void
		@target = void

	onbeforeupdate: !->
		@controlled = \isOpen of @attrs
		@attrs.interactionKind ?= \click
		if @controlled
			@isOpen = @attrs.isOpen
		if @target = @attrs.children.0
			@target = {} <<< @target
			attrs = @target.attrs = {} <<< @target.attrs
			attrs.class = os.class do
				"active": @isOpen
				"Popover__target"
				attrs.class
			switch @attrs.interactionKind
			| \click
				{onclick} = attrs
				attrs.onclick = (...args) !~>
					@interaction not @isOpen
					onclick? ...args
			| \contextmenu
				{oncontextmenu} = attrs
				attrs.oncontextmenu = (...args) !~>
					@interaction not @isOpen
					oncontextmenu? ...args
					os.isLockContextMenu = yes
					os.contextMenuList and= []

	onupdate: !->
		if @isOpen
			if @popper
				@popper.update!
			else
				@el = document.createElement \div
				@el.className = "Popover__popper Portal"
				portalEl = @dom.closest \.Portal
				portalEl.appendChild @el
				m.mount @el,
					view: ~>
						m \.Popover,
							class: os.class do
								@attrs.class
							style: os.style do
								@attrs.style
							os.castFuncVal @attrs.content,, @interactionClose
				@popper = os.createPopper @dom, @el,
					placement: @attrs.placement
					offset: [0 -1]
				@popper.forceUpdate!
				document.body.addEventListener \mousedown @onmousedownGlobal
		else
			@close!

	interaction: (isOpen) !->
		if @controlled
			@attrs.oninteraction? isOpen
		else
			@isOpen = isOpen
		m.redraw!

	interactionClose: !->
		@interaction no
		m.redraw!

	onmousedownGlobal: (event) !->
		unless @el.contains event.target or @dom.contains event.target
			@interaction not @isOpen
			m.redraw!

	close: !->
		if @popper
			@popper.destroy!
			@popper = void
			m.mount @el
			@el.remove!
			@el = void
			document.body.removeEventListener \mousedown @onmousedownGlobal

	onremove: !->
		@close!

	view: ->
		@target
