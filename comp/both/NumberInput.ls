NumberInput = os.comp do
	oninit: !->
		@input = void

	spin: (amount) !->
		el = @input.state.input.dom
		el.stepUp amount
		@attrs.oninput? el.value

	oninputInput: (event) !->
		@attrs.oninput? event.target.value

	onclickMinus: (event) !->
		@spin -1

	onclickPlus: (event) !->
		@spin 1

	view: ->
		m InputGroup,
			class:
				"NumberInput"
				@attrs.class
			style:
				@attrs.style
			m Button,
				icon: \minus
				onclick: @onclickMinus
			@input =
				m TextInput,
					type: \number
					required: @attrs.required
					value: @attrs.value
					oninput: @oninputInput
			m Button,
				icon: \plus
				onclick: @onclickPlus
