PasswordInput = os.comp do
	oninit: !->
		@input = void
		@isShowPassword = no

	oninputInput: (event) !->
		@attrs.oninput? event.target.value

	onclickIsShowPassword: (event) !->
		not= @isShowPassword

	view: ->
		m InputGroup,
			class:
				"disabled": @attrs.disabled
				"PasswordInput--isShowPassword": @isShowPassword
				"PasswordInput"
				@attrs.class
			style:
				@attrs.style
			@input =
				m TextInput,
					required: @attrs.required
					disabled: @attrs.disabled
					value: @attrs.value
					oninput: @oninputInput
			m Button,
				icon: @isShowPassword and \eye-slash or \eye
				onclick: @onclickIsShowPassword
