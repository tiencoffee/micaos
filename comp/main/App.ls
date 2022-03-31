App =
	oninit: !->
		for k, val of os
			@[k] = val
		@publicMethodNames = {}
		for k, val of getPublicMethods no
			@[k] = val
			@publicMethodNames[k] = yes
		for k, val of getPrivateMethods no
			@[k] = val
		@bind @
		os := @
		@taskbarHeight = 37
		@updateDesktop!
		@apps = []
		@tasks = []
		@bgType = \color
		@bgColor = \#000
		@bgImgPath = void
		@bgImgFit = \cover
		@bgImgDataUrl = void
		@isLockContextMenu = no
		@contextMenuList = void
		@contextMenuOncloses = []
		@contextMenuPopper = void
		@loaded = no

	oncreate: !->
		await fs.init do
			type: Window.PERSISTENT
			bytes: 1073741824
		for path in Paths\C/apps/*
			await @installApp path, path, \local
		for path in Paths\C/imgs/**/*.*
			data = await @fetch path, \arrayBuffer
			await @writeFile path, data
		addEventListener \resize @onresize
		document.body.addEventListener \contextmenu @oncontextmenu
		addEventListener \message @onmessage
		@loaded = yes
		m.redraw!
		@setBgImg \/C/imgs/bg/1.jpg
		@runTask \/C/apps/FileManager/app.yml,
			maximized: yes
			header: no
			skipTaskbar: yes
			transparent: yes
			args:
				isDesktop: yes
				viewMode: \desktop
		setTimeout !~>
			@runTask \/C/apps/FileManager/app.yml
		, 2000

	updateDesktop: !->
		@desktopWidth = innerWidth
		@desktopHeight = innerHeight - @taskbarHeight
		m.redraw!

	showContextMenu: (event, ...items) !->
		unless @isLockContextMenu
			if typeof items[* - 1] is \function
				onclose = items.pop!
				@contextMenuOncloses.unshift onclose
			@[]contextMenuList.push items

	closeContextMenu: !->
		for onclose in @contextMenuOncloses
			onclose!
		@isLockContextMenu = no
		@contextMenuList = void
		@contextMenuOncloses = []
		if @contextMenuPopper
			@contextMenuPopper.destroy!
			@contextMenuPopper = void
		m.mount contextMenuEl

	oncontextmenuTaskbar: (event) !->
		@showContextMenu event,
			* text: "Vị trí"
				submenu:
					* text: "Trên"
					* text: "Dưới"
			* text: "Khóa vị trí"

	onresize: (event) !->
		@updateDesktop!

	oncontextmenu: (event) !->
		event.preventDefault!
		[items] = @createContextMenuItems @contextMenuList
		if items.length
			@isLockContextMenu = yes
			m.mount contextMenuEl,
				view: ~>
					m Menu,
						class: "App__contextMenu"
						items: items
						onitemclick: @closeContextMenu
						onoutsideclick: @closeContextMenu
			@contextMenuPopper = @createPopper do
				getBoundingClientRect: ~>
					left: event.x
					top: event.y
					right: event.x
					bottom: event.y
					width: 0
					height: 0
				contextMenuEl
				placement: \bottom-start
				flips: \top-start
		else
			@closeContextMenu!
		m.redraw!

	onmessage: (event) !->
		{data} = event
		if Array.isArray data
			[type, name, tid, mid, args] = data
			if task = @tasks.find (.tid is tid)
				switch type
				| \umu
					if @publicMethodNames[name]
						args = @castArr args
						try
							result = await task[name] ...args
						catch
							result = e
							isErr = yes
						task.postMessage [type, mid, result, isErr] \*

	view: ->
		m \.App,
			if @loaded
				m \.App__content,
					switch @bgType
					| \color
						m \.App__bg.App__bgColor,
							style:
								backgroundColor: @bgColor
					| \img
						m \img.App__bg.App__bgImg,
							style: @style do
								objectFit: @bgImgFit
							src: @bgImgDataUrl
					m \.App__tasks,
						@tasks.map (task) ~>
							m task,
								key: task.pid
					m \.App__taskbar,
						style: @style do
							height: @taskbarHeight
						oncontextmenu: @oncontextmenuTaskbar
						m \.App__taskbarTasks,
							@tasks.map (task) ~>
								if task.skipTaskbar
									m.fragment do
										key: task.pid
								else
									m Popover,
										key: task.pid
										style:
											width: 200
										interactionKind: \contextmenu
										content: (close) ~>
											m Menu,
												basic: yes
												fill: yes
												items:
													* header: task.app.name
													* text: "Đóng"
														icon: \close
														color: \red
														onclick: !~>
															close!
															task.close!
										m Button,
											class: @class do
												"App__taskbarTask"
												"App__taskbarTask--#{task.pid}"
											width: 200
											icon: task.app.icon
											onclick: (event) !~>
												task.minimize!
											task.title
			else
				m \.App__loader,
					m Spinner
					m \.App__loaderText,
						"Đang tải"
