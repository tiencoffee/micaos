class Task
	(app, env, resolve, code, styl) ->
		for k, val of staticMethods
			@[k] = val
		for k, val of getPublicMethods yes
			@[k] = val
		for k, val of getPrivateMethods yes
			@[k] = val
		@bind @
		@app = app
		@pid = @uniqId!
		@tid = @uuid!
		@name = app.name
		@icon = app.icon
		@title = env.title ? app.title
		@width = env.width or app.width
		@height = env.height or app.height
		@x = env.x ? app.x ? Math.floor os.desktopWidth / 2 - @width / 2
		@y = env.y ? app.y ? Math.floor os.desktopHeight / 2 - @height / 2
		@minimizable = env.minimizable ? app.minimizable
		@maximizable = env.maximizable ? app.maximizable
		@minimized = env.minimized ? app.minimized
		@maximized = env.maximized ? app.maximized
		@admin = env.admin ? app.admin
		@resolve = resolve
		@moving = no
		@didMaximize = no

	oncreate: (vnode) !->
		@dom = vnode.dom
		@updateRectDom!

	minimize: (val) ->
		val ?= not @minimized
		if @minimizable
			if val isnt @minimized
				@minimized = val
				m.redraw!
				return yes
		no

	maximize: (val) ->
		val ?= not @maximized
		if @maximizable
			if val isnt @maximized
				@maximized = val
				@didMaximize = yes
				m.redraw!
				return yes
		no

	close: (val) ->
		index = os.tasks.indexOf @
		if index >= 0
			os.tasks.splice index, 1
			@resolve val
			m.redraw!

	updateXYDom: !->
		@dom.style.left = @x + \px
		@dom.style.top = @y + \px

	updateSizeDom: !->
		@dom.style.width = @width + \px
		@dom.style.height = @height + \px

	updateRectDom: !->
		@updateXYDom!
		@updateSizeDom!

	onpointerdownTitle: (event) !->
		event.target.setPointerCapture event.pointerId
		@moving = yes

	onpointermoveTitle: (event) !->
		event.redraw = no
		if @moving
			if @maximized
				@x = (Math.floor @clamp event.x - @width / 2 os.desktopWidth - @width) - 1
				@y = -1
				@maximize no
			@x += event.movementX
			@y += event.movementY
			@updateXYDom!

	onlostpointercaptureTitle: (event) !->
		if @moving
			@moving = no
			@x = @clamp @x, os.desktopWidth - @width
			@y = @clamp @y, os.desktopHeight - @height
			@updateXYDom!

	onbeforeremove: (vnode) ->
		anim = @dom.animate do
			* transform: "scale(.9)"
				opacity: 0
			* duration: 400
				easing: "cubic-bezier(.22,1,.36,1)"
		.finished

	onremove: !->
		@dom = void

	view: ->
		m \.Task,
			class: @class do
				"Task--moving": @moving
				"Task--didMaximize": @didMaximize
				"Task--minimized": @minimized
				"Task--maximized": @maximized
			m \.Task__content,
				m \.Task__header,
					m Button,
						class: "Task__icon"
						basic: yes
						small: yes
						icon: @icon
					m \.Task__title,
						onpointerdown: @onpointerdownTitle
						onpointermove: @onpointermoveTitle
						onlostpointercapture: @onlostpointercaptureTitle
						@title
					m \.Task__buttons,
						m Button,
							class: "Task__button"
							basic: yes
							small: yes
							icon: \minus
							onclick: !~>
								@minimize!
						m Button,
							class: "Task__button"
							basic: yes
							small: yes
							icon: \plus
							onclick: !~>
								@maximize!
						m Button,
							class: "Task__button"
							basic: yes
							small: yes
							color: \red
							icon: \times
							onclick: !~>
								@close!
				m \.Task__body,
					m \iframe.Task__iframe

staticMethods = os

function getPublicMethods isTask
	readFile: (path, type = \text) ->
		type = type.charAt!toUpperCase! + type.substring 1
		fs.readFile path, type: type

	writeFile: (path, data) ->
		file = await fs.writeFile path, data
		@makeEntry file

	appendFile: (path, data) ->
		file = await fs.appendFile path, data
		@makeEntry file

	removeFile: (path) ->
		res = await fs.unlink path
		res isnt no

	createDir: (path) ->
		dir = await fs.mkdir path
		@makeEntry dir

	readDir: (path, isDeep) ->
		fs.readdir path, deep: isDeep

	removeDir: (path) ->
		res = await fs.rmdir path
		res isnt no

	getEntry: (path) ->
		entry = await fs.getEntry path
		@makeEntry entry

	existsEntry: (path) ->
		fs.exists path

	copyEntry: (path, newPath, isCreate) ->
		entry = await fs.copy path, newPath, create: isCreate
		@makeEntry entry

	moveEntry: (path, newPath, isCreate) ->
		entry = await fs.rename path, newPath, create: isCreate
		@makeEntry entry

	installApp: (url, path, source) !->
		path = @normPath path
		switch source
		| \local
			results = await Promise.allSettled [
				@fetch "#path/app.yml"
				@fetch "#path/app.ls"
				@fetch "#path/app.styl"
			]
			[pkg, code, styl] = results.map (.value)
			if pkg
				pkg = jsyaml.safeLoad pkg
				app =
					name: pkg.name
					title: pkg.title ? pkg.name
					icon: pkg.icon ? \window
					path: path
					x: pkg.x
					y: pkg.y
					width: pkg.width or 800
					height: pkg.height or 600
					minimizable: pkg.minimizable ? yes
					maximizable: pkg.maximizable ? yes
					minimized: pkg.minimized ? no
					maximized: pkg.maximized ? no
					type: pkg.type or \user
					admin: admin ? no
				await @writeFile "#path/app.yml" pkg
				if code
					await @writeFile "#path/app.ls" code
				if styl
					await @writeFile "#path/app.styl" styl
				os.apps.push app
				m.redraw!

	runTask: (path, env = {}) ->
		path = @dirPath path
		if app = os.apps.find (.path is path)
			new Promise (resolve) !~>
				code = await @readFile "#path/app.ls"
				try
					styl = await @readFile "#path/app.styl"
				catch
					styl = ""
				task = new Task app, env, resolve, code, styl
				os.tasks.push task
				m.redraw!
		else
			throw Error "Không tìm thấy ứng dụng"

	closeTask: (pid) ->
		if task = os.tasks.find (.pid is pid)
			task.close!
		else
			throw Error "Không tìm thấy task"

function getPrivateMethods isTask
	entryToPath: (entry) ->
		if typeof entry is \string => entry
		else entry.path

	makeEntry: (entry) ->
		stat = await fs.stat entry
		entry =
			name: stat.name
			path: stat.fullPath
			mtime: stat.modificationTime
			size: stat.size
			isDir: stat.isDir
			isFile: stat.isFile
			ext: @extPath stat.name
		entry.icon = await @getEntryIcon entry
		entry

	getEntryIcon: (entry) ->
		if entry.isDir
			\folder-blank
		else
			switch entry.ext
			| <[ls styl stylus pug html htm css js json lson yml yaml xml]>
				\file-code
			| <[txt]>
				\file-lines
			| <[png jpg jpeg gif webp]>
				\file-image
			| <[mp3 aac wav]>
				\file-music
			| <[mp4 webm]>
				\file-video
			| <[zip rar]>
				\file-zipper
			| <[csv]>
				\file-csv
			| <[pdf]>
				\file-pdf
			| <[doc]>
				\file-word
			else \file
