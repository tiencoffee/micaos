Tabs = os.comp do
	onbeforeupdate: !->
		@attrs.tabs = os.castNewArr @attrs.tabs
		for tab, i in @attrs.tabs
			tab.id ?= i
		if @tab = @attrs.tabs.find (.id is @attrs.tabId)
			@indeterminate = no
		else
			@tab = @attrs.tabs.0
			@indeterminate = yes

	onupdate: !->
		if tabEl = @dom.querySelector \.Tabs__tab.active
			if @attrs.vertical
				@indicator.dom.style <<<
					left: ""
					top: tabEl.offsetTop + \px
					width: \100%
					height: tabEl.offsetHeight + \px
			else
				@indicator.dom.style <<<
					left: tabEl.offsetLeft + \px
					top: ""
					width: tabEl.offsetWidth + \px
					height: \3px

	onclickTab: (tab, event) !->
		event.redraw = no
		if @indeterminate or @tab.id isnt tab.id
			@attrs.onchange? tab.id
			m.redraw!

	view: ->
		m \.Tabs,
			class: os.class do
				"Tabs--#{@attrs.vertical and \vertical or \horizontal}"
			m \.Tabs__tabs,
				@indicator =
					m \.Tabs__indicator
				@attrs.tabs.map (tab) ~>
					m \.Tabs__tab,
						class: os.class do
							"active": @tab.id is tab.id
						onclick: (event) !~>
							@onclickTab tab, event
						if tab.icon
							m Icon,
								class: "Tabs__icon"
								name: tab.icon
						m \.Tabs__title,
							tab.title
			m \.Tabs__panel,
				if @tab
					m.fragment do
						key: @tab.id
						os.castFuncVal @tab.panel,, @
