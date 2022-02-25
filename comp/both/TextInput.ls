TextInput = os.comp do
	oninit: !->
		@input = void

	view: ->
		m \.TextInput,
			class: os.class do
				"disabled": @attrs.disabled
				@attrs.class
			style: os.style do
				@attrs.style
			if @attrs.icon
				m Icon,
					class: "TextInput__icon"
					name: @attrs.icon
			@input =
				m \input.TextInput__input,
					type: @attrs.type
					required: @attrs.required
					disabled: @attrs.disabled
					value: @attrs.value
					oninput: @attrs.oninput
			if @attrs.rightIcon
				m Icon,
					class: "TextInput__icon"
					name: @attrs.rightIcon
