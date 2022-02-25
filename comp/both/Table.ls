Table = os.comp do
	view: ->
		m \.Table,
			class: os.class do
				"Table--hasHeader": @attrs.header
				"Table--bordered": @attrs.bordered
				"Table--striped": @attrs.striped
				"Table--interactive": @attrs.interactive
				@attrs.class
			style: os.style do
				@attrs.style
			m \.Table__table,
				os.castFuncVal @attrs.header
				os.castFuncVal @attrs.body
