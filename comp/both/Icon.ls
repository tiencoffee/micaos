Icon = os.comp do
	onbeforeupdate: (old) !->
		if not old or @attrs.name isnt old.name
			[kind, val] = (@attrs.name or "")toString!split \:
			unless val
				val = kind
				kind =
					if /^\d{6,}$/test val => \flaticon
					else if val and val isnt \blank => \fas
					else \blank
			val = switch kind
				| \flaticon => "https://cdn-icons-png.flaticon.com/24/#{val.slice 0 -3}/#val.png"
				| \flag => "https://cdn.jsdelivr.net/npm/picon@22.3.9/flags/#val.svg"
				| \blank => void
				else val
			@kind = kind
			@val = val

	view: ->
		switch @kind
		| \fas \fa \far \fal \fat \fad \fab
			m \span.Icon.Icon__fa,
				class: os.class do
					"#@kind fa-#@val"
					@attrs.class
		| \flaticon \flag \https \http
			m \img.Icon.Icon__img,
				class: os.class do
					@attrs.class
				src: @val
		| \blank
			m \span.Icon.Icon__blank,
				class: os.class do
					@attrs.class
