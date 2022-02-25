Slider = os.comp do
	oninit: !->
		@moving = no

	onbeforeupdate: (old) !->
		@attrs.min ?= 0
		@attrs.max ?= 10
		@attrs.step or= 1
		@attrs.labelStep or= @attrs.step
		if not old
		or @attrs.min isnt old.attrs.min
		or @attrs.max isnt old.attrs.max
		or @attrs.step isnt old.attrs.step
		or @attrs.labelPrecision isnt old.attrs.labelPrecision
		or @attrs.labelStep isnt old.attrs.labelStep
			@updateRange!
		if not old or @attrs.value isnt old.attrs.value
			@perc = os.clamp (@attrs.value - @attrs.min) / @range * 100 0 100

	updateRange: !->
		el = document.createElement \input
		el.type = \range
		el{min, max, step} = @attrs
		el.value = @attrs.min
		@range = @attrs.max - @attrs.min
		halfStepPerc = @attrs.step / @range * 50
		@vals = []
		do
			num = el.valueAsNumber
			perc = (num - @attrs.min) / @range * 100 + halfStepPerc
			@vals.push [num, perc]
			el.stepUp!
		until num is el.valueAsNumber
		el.step = @attrs.labelStep
		el.value = @attrs.min
		@labels = []
		labelPrecision = @attrs.labelPrecision ? @attrs.labelStep.toString!split \. .1?length or 0
		do
			num = el.valueAsNumber
			perc = (num - @attrs.min) / @range * 100
			num2 = +num.toFixed labelPrecision
			@labels.push [num2, perc]
			el.stepUp!
		until num is el.valueAsNumber

	onpointermove: (event) !->
		event.redraw = no
		if event.type is \pointerdown and event.button is 0
			event.currentTarget.setPointerCapture event.pointerId
			@moving = yes
			m.redraw!
		if @moving
			x = event[@attrs.vertical and \pageY or \pageX]
			offsetLeft = event.currentTarget[@attrs.vertical and \offsetTop or \offsetLeft]
			offsetWidth = event.currentTarget[@attrs.vertical and \offsetHeight or \offsetWidth]
			perc = (x - offsetLeft - 10) / (offsetWidth - 20) * 100
			if @attrs.vertical
				perc = 100 - perc
			val = @vals.find (.1 > perc) or @vals[* - 1]
			unless val.0 is @attrs.value
				@attrs.oninput? val.0
				m.redraw!

	onlostpointercapture: (event) !->
		@moving = no

	view: ->
		left = @attrs.vertical and \bottom or \left
		m \.Slider,
			class: os.class do
				"Slider--moving": @moving
				"disabled": @attrs.disabled
				"Slider--#{@attrs.vertical and \vertical or \horizontal}"
				@attrs.class
			style: os.style do
				@attrs.style
			onpointerdown: @onpointermove
			onpointermove: @onpointermove
			onlostpointercapture: @onlostpointercapture
			m \.Slider__range,
				m \.Slider__track
				m \.Slider__thumb,
					style:
						(left): @perc + \%
			m \.Slider__labels,
				@labels.map (label) ~>
					m \.Slider__label,
						style:
							(left): label.1 + \%
						label.0
