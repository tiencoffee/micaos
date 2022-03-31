send = no
staticMethods = os

function getPublicMethods isTask
	readFile: (path, type = \text) ->
		path = @entryToPath path
		type = type.charAt 0 .toUpperCase! + type.substring 1
		fs.readFile path, type: type

	writeFile: (path, data) ->
		path = @entryToPath path
		file = await fs.writeFile path, data
		@makeEntry file

	appendFile: (path, data) ->
		path = @entryToPath path
		file = await fs.appendFile path, data
		@makeEntry file

	removeFile: (path) ->
		path = @entryToPath path
		res = await fs.unlink path
		res isnt no

	createDir: (path) ->
		path = @entryToPath path
		dir = await fs.mkdir path
		@makeEntry dir

	readDir: (path) ->
		path = @entryToPath path
		entries = await fs.readdir path
		Promise.all entries.map @makeEntry

	removeDir: (path) ->
		path = @entryToPath path
		res = await fs.rmdir path
		res isnt no

	getEntry: (path) ->
		path = @entryToPath path
		entry = await fs.getEntry path
		@makeEntry entry

	existsEntry: (path) ->
		path = @entryToPath path
		fs.exists path

	copyEntry: (path, newPath, isCreate) ->
		path = @entryToPath path
		entry = await fs.copy path, newPath, create: isCreate
		@makeEntry entry

	moveEntry: (path, newPath, isCreate) ->
		path = @entryToPath path
		entry = await fs.rename path, newPath, create: isCreate
		@makeEntry entry

	installApp: (url, path, source) !->
		path = @normPath path
		switch source
		| \local
			if yaml = await @fetch "#path/app.yml"
				pkg = jsyaml.safeLoad yaml
				app =
					name: pkg.name
					title: pkg.title
					icon: pkg.icon ? \window
					path: path
					x: pkg.x
					y: pkg.y
					width: pkg.width
					height: pkg.height
					minWidth: pkg.minWidth
					minHeight: pkg.minHeight
					maxWidth: pkg.maxWidth
					maxHeight: pkg.maxHeight
					minimized: pkg.minimized
					maximized: pkg.maximized
					minimizable: pkg.minimizable
					maximizable: pkg.maximizable
					resizable: pkg.resizable
					movable: pkg.movable
					focusable: pkg.focusable
					header: pkg.header
					skipTaskbar: pkg.skipTaskbar
					acceptFirstMouse: pkg.acceptFirstMouse
					transparent: pkg.transparent
					type: pkg.type or \user
					admin: pkg.admin
				await @writeFile "#path/app.yml" yaml
				try
					code = await @fetch "#path/app.ls"
					await @writeFile "#path/app.ls" code
				try
					styl = await @fetch "#path/app.styl"
					await @writeFile "#path/app.styl" styl
				os.apps.push app
				m.redraw!

	runTask: (path, env = {}, cid) ->
		path = @dirPath path
		if app = os.apps.find (.path is path)
			new Promise (resolve) !~>
				code = await @readFile "#path/app.ls"
				try
					styl = await @readFile "#path/app.styl"
				catch
					styl = ""
				task = new Task app, env, cid, @, resolve, code, styl
				os.tasks.push task
				m.redraw!
		else
			throw Error "Không tìm thấy ứng dụng: '#path'"

	setTaskEvt: (cid, ...evts) ->
		if task = os.tasks.find ~> it.cid is cid and it.parent is @
			for evt in evts
				task.evts.push evt

	setTaskEvtByPid: (pid, ...evts) ->
		if task = os.tasks.find (.pid is pid)

	closeTask: (cid) ->
		if task = os.tasks.find ~> it.cid is cid and it.parent is @
			task.close!

	closeTaskByPid: (pid) ->
		if task = os.tasks.find (.pid is pid)
			task.close!
		else
			throw Error "Không tìm thấy task với pid '#pid'"

	setBgImg: (path) ->
		new Promise (resolve) !~>
			dataUrl = await @readFile path, \dataURL
			img = new Image
			img.onload = !~>
				os.bgType = \img
				os.bgImgPath = path
				os.bgImgDataUrl = dataUrl
				resolve!
				m.redraw!
			img.onerror = !~>
				resolve!
				m.redraw!
			img.src = dataUrl

	$initTask: ->
		unless @postMessage
			@postMessage = @iframe.contentWindow~postMessage
			@tid = crypto.randomUUID!
			tid: @tid
			publicMethodNames: Object.keys os.publicMethodNames
			args: @args

	$mousedownTask: (x, y, button) !->
		rect = @iframe.getBoundingClientRect!
		evt = new MouseEvent \mousedown,
			clientX: rect.x + x
			clientY: rect.y + y
			button: button
		document.body.dispatchEvent evt

	$contextMenuTask: (x, y, items) ->
		new Promise (resolve) !~>
			rect = @iframe.getBoundingClientRect!
			x := rect.x + x
			y := rect.y + y
			evt = new MouseEvent \contextmenu,
				clientX: x
				clientY: y
			call = (items) !~>
				for let item in items
					if item.onclick?
						cbId = item.onclick
						item.onclick = !~>
							resolve cbId
					if item.submenu
						call item.submenu
			call items
			os.showContextMenu evt, ...items, !~>
				resolve!
			document.body.dispatchEvent evt

function getPrivateMethods isTask
	entryToPath: (entry) ->
		path = if typeof entry is \string => entry else entry.path
		@normPath path

	makeEntry: (entry) ->
		stat = await fs.stat entry
		entry =
			name: stat.name
			path: stat.fullPath
			mtime: stat.modificationTime
			size: stat.size
			isDir: stat.isDirectory
			isFile: stat.isFile
			ext: if stat.isFile => @extPath stat.name else ""
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

m.mount appEl, App
