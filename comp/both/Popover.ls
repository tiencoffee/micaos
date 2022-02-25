Popover = os.comp do
	oninit: !->
		@isOpen = no
		@popper = void
		@el = void
		@target = void

	onbeforeupdate: !->
		@controlled = \isOpen of @attrs
		if @controlled
			@isOpen = @attrs.isOpen
		if @target = @attrs.children.0
			@target = {} <<< @target
			attrs = @target.attrs = {} <<< @target.attrs
			attrs.class = os.class do
				"hover": @isOpen
				"Popover__target"
				attrs.class
			{onclick} = attrs
			attrs.onclick = (...args) !~>
				@interaction not @isOpen
				onclick? ...args

	onupdate: !->
		if @isOpen
			if @popper
				@popper.update!
			else
				@el = document.createElement \div
				@el.className = "Popover Portal"
				portalEl = @dom.closest \.Portal
				portalEl.appendChild @el
				m.mount @el,
					view: ~>
						m \.Popover__content,
							os.castFuncVal @attrs.content
				@popper = os.createPopper @dom, @el,
					placement: @attrs.placement
					offset: [0 -1]
				@popper.forceUpdate!
				document.addEventListener \mousedown @onmousedownGlobal
		else
			@close!

	interaction: (isOpen) !->
		if @controlled
			@attrs.oninteraction? isOpen
		else
			@isOpen = isOpen

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
			document.removeEventListener \mousedown @onmousedownGlobal

	onremove: !->
		@close!

	view: ->
		@target
