Button = os.comp do
	onbeforeupdate: !->
		@attrs.type ?= \button

	view: ->
		m \button.Button,
			class: os.class do
				"active": @attrs.active
				"disabled": @attrs.disabled
				"Button--basic": @attrs.basic
				"Button--#{@attrs.color}": @attrs.color
				"Button--#{@attrs.alignText}": @attrs.alignText
				"Button--hasColor": @attrs.color
				@attrs.class
			style: os.style do
				@attrs.style
			disabled: @attrs.disabled
			type: @attrs.type
			onclick: @attrs.onclick
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
