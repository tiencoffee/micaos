Icon = os.comp do
	onbeforeupdate: !->
		names = (@attrs.name or "")toString!split \:
		if names.length is 1
			if /^\d{6,}$/test names.0
				names = [\flaticon "https://cdn-icons-png.flaticon.com/24/#{names.0.slice 0 -3}/#{names.0}.png"]
			else if names.0 and names.0 isnt \blank
				names = [\fas names.0]
			else
				names = [\blank]
		[@kind, @val] = names

	view: ->
		switch @kind
		| \fas \fa \far \fal \fat \fad \fab
			m \span.Icon.Icon__fa,
				class: os.class do
					"#@kind fa-#@val"
					@attrs.class
		| \flaticon \https \http
			m \img.Icon.Icon__img,
				class: os.class do
					@attrs.class
				src: @val
		| \blank
			m \span.Icon.Icon__blank,
				class: os.class do
					@attrs.class
