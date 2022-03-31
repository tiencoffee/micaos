Icon = os.comp do
	onbeforeupdate: (old) !->
		if not old or @attrs.size isnt old.size
			{size} = @attrs
			if size?
				@width = "clamp(20px,#{os.addEndStr size, \px})"
				@fontSize = size
			else
				@width = void
				@fontSize = void
		if not old or @attrs.name isnt old.name
			[kind, val] = (@attrs.name or "")toString!split \:
			unless val
				val = kind
				kind =
					if /^\d{6,}$/test val => \flaticon
					else if val and val isnt \blank => \fas
					else \blank
			val = switch kind
				| \flaticon => "https://cdn-icons-png.flaticon.com/#{@getFlaticonSize!}/#{val.slice 0 -3}/#val.png"
				| \flag => "https://cdn.jsdelivr.net/npm/picon@22.3.9/flags/#val.svg"
				| \blank => void
				else val
			@kind = kind
			@val = val

	getFlaticonSize: ->
		{fontSize} = @
		if fontSize <= 24 => 24
		else if fontSize <= 32 => 32
		else if fontSize <= 64 => 64
		else if fontSize <= 128 => 128
		else if fontSize <= 256 => 256
		else if fontSize <= 512 => 512
		else 24

	view: ->
		switch @kind
		| \fas \fa \far \fal \fat \fad \fab
			m \span.Icon.Icon__fa,
				class: os.class do
					"#@kind fa-#@val"
					@attrs.class
				style: os.style do
					width: @width
					height: @width
					fontSize: @fontSize
					@attrs.style
		| \flaticon \flag \https \http
			m \img.Icon.Icon__img,
				class: os.class do
					@attrs.class
				style: os.style do
					width: @width
					height: @width
					@attrs.style
				src: @val
		| \blank
			m \span.Icon.Icon__blank,
				class: os.class do
					@attrs.class
				style: os.style do
					width: @width
					height: @width
					@attrs.style
