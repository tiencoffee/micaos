Radio = os.comp do
	view: ->
		m \label.Radio,
			class: os.class do
				"disabled": @attrs.disabled
				@attrs.class
			m \input.Radio__input,
				type: \radio
				required: @attrs.required
				disabled: @attrs.disabled
				checked: @attrs.checked
				oninput: @attrs.oninput
			if @attrs.text
				m \.Radio__text,
					@attrs.text
