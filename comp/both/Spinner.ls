Spinner = os.comp do
	onbeforeupdate: !->
		@attrs.size ?= 48
		@attrs.max ?= 1
		if @attrs.value?
			@indeterminate = no
		else
			@attrs.value = @attrs.max / 4
			@indeterminate = yes

	view: ->
		size = @attrs.size
		center = size / 2
		radius = center - 2
		bottom = size - 4
		m \.Spinner,
			class: os.class do
				"Spinner--#{@attrs.color}": @attrs.color
				@attrs.class
			style: os.style do
				@attrs.style
			m \svg.Spinner__svg,
				width: size
				height: size
				viewBox: "0 0 #size #size"
				m \path.Spinner__track,
					d: "M#center 2 a#radius #radius 0 1 1 0 #bottom a#radius #radius 0 1 1 0 -#bottom"
				m \path.Spinner__bar,
					class: os.class do
						"fa-spin": @indeterminate
					style:
						strokeDasharray: 1
						strokeDashoffset: 1 - (@attrs.value / @attrs.max)
					pathLength: 1
					d: "M#center 2 a#radius #radius 0 1 1 0 #bottom a#radius #radius 0 1 1 0 -#bottom"
