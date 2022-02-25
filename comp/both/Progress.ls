Progress = os.comp do
	onbeforeupdate: !->
		@attrs.max ?= 1
		@attrs.value ?= @attrs.max

	view: ->
		m \.Progress,
			class: os.class do
				"Progress--#{@attrs.color}": @attrs.color
				@attrs.class
			style: os.style do
				@attrs.style
			m \.Progress__bar,
				style:
					width: (@attrs.value / @attrs.max) * 100 + \%
