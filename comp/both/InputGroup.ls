InputGroup = os.comp do
	view: ->
		m \.InputGroup,
			class: os.class do
				@attrs.class
			style: os.style do
				@attrs.style
			@attrs.children
