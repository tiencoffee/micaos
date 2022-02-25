Switch = os.comp do
	view: ->
		m \label.Switch,
			class: os.class do
				"disabled": @attrs.disabled
				"Switch--checked": @attrs.checked
				@attrs.class
			m \.Switch__track,
				m \.Switch__thumb
			m \input.Switch__input,
				type: \checkbox
				required: @attrs.required
				disabled: @attrs.disabled
				checked: @attrs.checked
				oninput: @attrs.oninput
			if @attrs.text
				m \.Switch__text,
					@attrs.text
