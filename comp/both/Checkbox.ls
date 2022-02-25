Checkbox = os.comp do
	view: ->
		m \label.Checkbox,
			class: os.class do
				"disabled": @attrs.disabled
				@attrs.class
			m \input.Checkbox__input,
				type: \checkbox
				required: @attrs.required
				disabled: @attrs.disabled
				checked: @attrs.checked
				oninput: @attrs.oninput
			if @attrs.text
				m \.Checkbox__text,
					@attrs.text
