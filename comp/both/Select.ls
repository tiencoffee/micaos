Select = os.comp do
	oninit: !->
		@isOpen = no

	onbeforeupdate: !->
		@attrs.items = @createItems @attrs.items
		if @item = @attrs.items.find (.value is @attrs.value)
			@indeterminate = no
		else
			@item = @attrs.items.0
			@indeterminate = yes

	createItems: (items2) ->
		items = []
		item = void
		for item2, i in os.castArr items2
			if item2 is void
				if item and not item.divider
					item = {+divider}
					items.push item
			else
				if typeof item2 isnt \object or item2 is null
					item2 = value: item2
				if item2.header
					if item and item.divider
						items[* - 1] = item2
					else
						items.push item2
					item = item2
				else
					value = if \value of item2 => item2.value else item2.text
					unless items.some (.value is value)
						item =
							icon: item2.icon
							disabled: item2.disabled
							text: (if \text of item2 => item2.text else value) + ""
							value: value
						items.push item
		if item and item.divider
			items.pop!
		items

	onclick: (event) !->
		event.redraw = no
		if event.target is event.currentTarget
			if @attrs.items.length
				not= @isOpen
				if @isOpen
					unless @popper
						@el = document.createElement \div
						@el.className = "Select__popper scrollbar-inset"
						@el.style.maxHeight = Math.floor(innerHeight / 2 - @dom.offsetHeight / 2) + \px
						@dom.appendChild @el
						m.mount @el,
							view: ~>
								m \.Select__items,
									@attrs.items.map (item) ~>
										if item.divider
											m \.Select__divider
										else if item.header
											m \.Select__header,
												item.header
										else
											m \.Select__item,
												class: os.class do
													"active": @item.value is item.value
													"disabled": item.disabled
												onclick: (event) !~>
													@onclickItem item, event
												m \.Select__itemIcon,
													m Icon,
														name: item.icon
												m \.Select__itemText,
													item.text
						@popper = os.createPopper @dom, @el,
							placement: \bottom
							offset: [0 -1]
							flips: [\top]
							allowedFlips: [\bottom \top]
						@popper.forceUpdate!
						document.body.addEventListener \mousedown @onmousedownGlobal
						itemEl = @el.querySelector \.active
						top = Math.round itemEl.offsetTop - @el.offsetHeight / 2 + itemEl.offsetHeight / 2
						@el.scrollTop = top if top > 0
				else
					@close!
				m.redraw!

	onclickItem: (item, event) !->
		if @indeterminate or @item.value isnt item.value
			@attrs.oninput item.value
		@close!

	onmousedownGlobal: (event) !->
		unless @dom.contains event.target
			@close!
			m.redraw!

	close: !->
		if @popper
			@isOpen = no
			@popper.destroy!
			@popper = void
			m.mount @el
			@el.remove!
			@el = void
			document.body.removeEventListener \mousedown @onmousedownGlobal

	onremove: !->
		@close!

	view: ->
		m Button,
			class:
				"Select"
				@attrs.class
			style:
				@attrs.style
			active: @isOpen
			disabled: @attrs.disabled
			alignText: \left
			icon: @item?icon
			rightIcon: \sort
			onclick: @onclick
			@item?text
