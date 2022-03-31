Menu = os.comp do
	onbeforeupdate: !->
		@attrs.root ?= @
		@attrs.parentItemId ?= ""
		@attrs.items = @createItems @attrs.items

	oncreate: !->
		if @attrs.root is @
			document.body.addEventListener \mousedown @onmousedownGlobal

	createItems: (items2) ->
		items = []
		item = void
		for item2, i in os.castArr items2
			id = "#{@attrs.parentItemId}-#i"
			if item2
				unless item2.hidden or \shown of item2 and not item2.shown
					if item2.header
						item2 = {item2.header, id}
						if item and item.divider
							items[* - 1] = item2
						else
							items.push item2
						item = item2
					else
						item = {...item2, id}
						items.push item
			else
				if item and not item.divider
					item = {+divider, id}
					items.push item
		if item and item.divider
			items.pop!
		items

	onclickItem: (item, event) !->
		event.redraw = no
		unless item.submenu
			if typeof item.onclick is \function
				item.onclick!
			@attrs.root.attrs.onitemclick? item
			@attrs.root.closeItem!

	onmouseenterItem: (item, event) !->
		event.redraw = no
		unless @item and item.id is @item.id
			@closeItem!
			if item.submenu
				@timo = setTimeout !~>
					@item = item
					@el = document.createElement \div
					@el.className = "Menu__submenu"
					event.target.appendChild @el
					m.mount @el,
						view: ~>
							m Menu,
								root: @attrs.root
								parentItemId: item.id
								items: item.submenu
					@popper = os.createPopper event.target, @el,
						placement: \right-start
						offset: [-5 0]
						tetherOffset: 33
						flips: [\left-start]
						allowedFlips: [\right-start \left-start]
					@timo = void
					m.redraw!
				, 300

	onmouseleaveItem: (item, event) !->
		event.redraw = no
		if item.submenu
			@clearTimo!

	onmousedown: (event) !->
		event.redraw = no
		if event.target is event.currentTarget
			@closeItem!

	onmousedownGlobal: (event) !->
		unless event.target.closest \.Menu
			@closeItem!
			@attrs.root.attrs.onoutsideclick?!
			m.redraw!

	clearTimo: !->
		if @timo
			clearTimeout @timo
			@timo = void

	closeItem: !->
		if @item
			@item = void
			@popper.destroy!
			@popper = void
			m.mount @el
			@el.remove!
			@el = void
			m.redraw!

	close: !->
		@clearTimo!
		@closeItem!
		if @attrs.root is @
			document.body.removeEventListener \mousedown @onmousedownGlobal

	onremove: !->
		@close!

	view: ->
		m \.Menu,
			class: os.class do
				"Menu--basic": @attrs.basic
				"Menu--fill": @attrs.fill
				@attrs.class
			onmousedown: @onmousedown
			@attrs.items.map (item) ~>
				if item.divider
					m \.Menu__divider,
						key: item.id
				else if item.header
					m \.Menu__header,
						key: item.id
						item.header
				else
					m \.Menu__item,
						key: item.id
						class: os.class do
							"active": @item and item.id is @item.id
							"disabled": item.disabled
							"Menu__item--#{item.color}": item.color
						onclick: (event) !~>
							@onclickItem item, event
						onmouseenter: (event) !~>
							@onmouseenterItem item, event
						onmouseleave: (event) !~>
							@onmouseleaveItem item, event
						m \.Menu__itemIcon,
							m Icon,
								name: item.icon
						m \.Menu__itemText,
							item.text
						if item.submenu
							m \.Menu__itemLabel,
								m Icon,
									name: \chevron-right
						else if item.label
							m \.Menu__itemLabel,
								item.label
