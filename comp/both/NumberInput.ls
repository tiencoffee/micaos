NumberInput = os.comp do
	oninit: !->
		@input = void

	spin: (amount) !->
		el = @input.state.input.dom
		el.stepUp amount
		@attrs.oninput? el.value

	oninputInput: (event) !->
		@attrs.oninput? event.target.value

	oncontextmenuInput: (event) !->
		@attrs.oncontextmenu? event
		os.showContextMenu event,
			* text: "Tăng lên"
				icon: \plus
				onclick: !~>
					@spin 1
			* text: "Giảm xuống"
				icon: \minus
				onclick: !~>
					@spin -1
			,,
			\TextInput-all

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
					oncontextmenu: @oncontextmenuInput
			m Button,
				icon: \plus
				onclick: @onclickPlus
