InputGroup = os.comp do
	view: ->
		tag = @attrs.isForm and \form or \div
		m "#tag.InputGroup",
			class: os.class do
				@attrs.class
			style: os.style do
				@attrs.style
			onsubmit: @attrs.onsubmit
			@attrs.children
