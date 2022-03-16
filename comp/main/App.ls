App =
	oninit: !->
		for k, val of os
			@[k] = val
		for k, val of getPublicMethods no
			@[k] = val
		for k, val of getPrivateMethods no
			@[k] = val
		@bind @
		os := @
		@taskbarHeight = 36
		@updateDesktop!
		@apps = []
		@tasks = []
		@loaded = no

	oncreate: !->
		await fs.init do
			type: Window.PERSISTENT
			bytes: 1073741824
		for path in Paths\C/apps/*
			await @installApp path, "/#path" \local
		addEventListener \resize @onresize
		@loaded = yes
		m.redraw!
		@runTask \/C/apps/FileManager/app.yml

	updateDesktop: !->
		@desktopWidth = innerWidth
		@desktopHeight = innerHeight - @taskbarHeight

	onresize: (event) !->
		@updateDesktop!

	view: ->
		m \.App,
			if @loaded
				m \.App__content,
					m \.App__tasks,
						@tasks.map (task) ~>
							m task
					m \.App__taskbar,
						style: @style do
							height: @taskbarHeight
						m \.App__taskbarTasks,
							@tasks.map (task) ~>
								m Button,
									class: @class do
										"App__taskbarTask"
									task.title
			else
				m \.App__loader,
					m Spinner
					m \.App__loaderText,
						"Đang tải"
