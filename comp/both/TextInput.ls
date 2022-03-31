TextInput = os.comp do
	oninit: !->
		@input = void

	oncontextmenuInput: (event) !->
		@attrs.oncontextmenu? event
		os.showContextMenu event,
			* text: "Sao chép"
				icon: \clone
				tags: [\TextInput-all \TextInput-copy]
				onclick: !~>
					@input.dom.focus!
					document.execCommand \copy
			* text: "Cắt"
				icon: \scissors
				tags: [\TextInput-all \TextInput-cut]
				onclick: !~>
					@input.dom.focus!
					document.execCommand \cut
			* text: "Dán"
				icon: \clipboard
				tags: [\TextInput-all \TextInput-paste]
				onclick: !~>
					@input.dom.focus!

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
					oncontextmenu: @oncontextmenuInput
			if @attrs.rightIcon
				m Icon,
					class: "TextInput__icon"
					name: @attrs.rightIcon
