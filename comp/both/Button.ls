Button = os.comp do
	onbeforeupdate: !->
		@attrs.type ?= \button

	view: ->
		m \button.Button,
			class: os.class do
				"active": @attrs.active
				"disabled": @attrs.disabled
				"Button--basic": @attrs.basic
				"Button--small": @attrs.small
				"Button--#{@attrs.color}": @attrs.color
				"Button--#{@attrs.alignText}": @attrs.alignText
				"Button--hasColor": @attrs.color
				"Button--onlyIcon": not @attrs.children.length and not (@attrs.icon and @attrs.rightIcon)
				@attrs.class
			style: os.style do
				width: @attrs.width
				@attrs.style
			disabled: @attrs.disabled
			type: @attrs.type
			onclick: @attrs.onclick
			oncontextmenu: @attrs.oncontextmenu
			if @attrs.icon
				m Icon,
					class: "Button__icon Button__leftIcon"
					name: @attrs.icon
			if @attrs.children.length
				m \.Button__text,
					@attrs.children
			if @attrs.rightIcon
				m Icon,
					class: "Button__icon Button__rightIcon"
					name: @attrs.rightIcon
