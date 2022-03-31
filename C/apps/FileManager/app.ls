await os.import do
	\filesize

App = os.comp do
	oninit: !->
		@tmpPath = \/
		@path = void
		@viewMode = os.args.viewMode or \list
		@sortBy = \name
		@sortOrder = 1
		@isShowDesktop = yes
		@entries = []
		@selEntries = []
		@selector = no
		@loading = no
		@undo = os.createUndoable!
		@load @tmpPath

	load: (path, skipUndo) !->
		unless @loading
			path = os.joinPath \/ path
			m.redraw!
			@loading = yes
			m.redraw!
			try
				@entries = await os.readDir path
				@sort!
				unless skipUndo
					@undo.add path
			catch
				@entries = e
			@selEntries = []
			@loading = no
			@tmpPath = path
			@path = path
			m.redraw!

	reload: !->
		@load @path, yes

	sort: !->
		@entries.sort (a, b) ~>
			if b.isDir - a.isDir
				that
			else
				orderName = a.name.localeCompare b.name
				switch @sortBy
				| \name
					orderName * @sortOrder
				| \mtime
					(a.mtime - b.mtime) * @sortOrder or orderName
				| \type
					(a.ext.localeCompare b.ext) * @sortOrder or orderName
				| \size
					(a.size - b.size) * @sortOrder or orderName

	onclickBack: (event) !->
		path = @undo.undo!
		@load path, yes

	onclickForward: (event) !->
		path = @undo.redo!
		@load path, yes

	onclickParent: (event) !->
		path = os.dirPath @path
		@load path

	onclickReload: (event) !->
		@reload!

	oninputPath: (event) !->
		@tmpPath = event.target.value

	onsubmitForm: (event) !->
		event.preventDefault!
		@load @tmpPath

	ondblclickEntry: (entry, event) !->
		if entry.isDir
			@load entry.path

	oncontextmenuEntry: (entry, event) !->
		unless @selEntries.includes entry
			@selEntries = [entry]
		os.showContextMenu event,
			* text: "Mở"
				onclick: !~>
					if entry.isDir
						@load entry.path
			* text: "Mở bằng"
				shown: entry.isFile
				submenu:
					* text: "Mở bằng ứng dụng khác..."
			* text: "Đặt làm hình nền"
				shown: entry.ext in <[jpg jpeg png webp gif]>
				onclick: !~>
					os.setBgImg entry
			,,
			* text: "Gửi qua"
				icon: \paper-plane
				submenu:
					* text: "Gửi qua FileIO"
						icon: \fad:arrow-down-to-bracket
			,,
			* text: "Sao chép"
				icon: \clone
			* text: "Cắt"
				icon: \scissors
			,,
			* text: "Đổi tên"
				icon: \pen-field
			* text: "Xóa"
				icon: \trash-alt
				color: \red
				onclick: !~>
					for entry in @selEntries
						if entry.isDir
							await os.removeDir entry
						else
							await os.removeFile entry
					@reload!
			,,
			* text: "Thông tin"
				icon: \circle-info

	onmousedownView: (event) !->
		if event.button is 0
			{x, y, currentTarget} = event
			@selector =
				x0: x
				y0: y
				x1: x
				y1: y
				x2: x
				y2: y
				offsetX: currentTarget.offsetLeft
				offsetY: currentTarget.offsetTop
				moving: no
				rects: [...@dom.querySelectorAll \.App__entry]map (.getBoundingClientRect!)
				oldSelEntries: if event.ctrlKey or event.shiftKey => [...@selEntries] else []
			@onmousemoveView event
			document.body.addEventListener \mousemove @onmousemoveView
			document.body.addEventListener \mouseup @onmouseupView
			addEventListener \blur @onmouseupView

	onmousemoveView: (event) !->
		if @selector
			{x, y} = event
			if event.type is \mousemove
				@selector.moving = yes
			{x0, y0, x1, y1, x2, y2, oldSelEntries} = @selector
			[x1, x2] = x0 < x and [x0, x] or [x, x0]
			[y1, y2] = y0 < y and [y0, y] or [y, y0]
			newSelEntries = []
			for rect, i in @selector.rects
				if x1 < rect.right and x2 >= rect.x and y1 < rect.bottom and y2 >= rect.y
					entry = @entries[i]
					newSelEntries.push entry
			if event.ctrlKey
				@selEntries = os.xorArr oldSelEntries, newSelEntries
			else if event.shiftKey
				@selEntries = os.unionArr oldSelEntries, newSelEntries
			else
				@selEntries = [...newSelEntries]
			@selector.x1 = x1
			@selector.y1 = y1
			@selector.x2 = x2
			@selector.y2 = y2
			m.redraw!

	onmouseupView: (event) !->
		if @selector
			@selector = void
			document.body.removeEventListener \mousemove @onmousemoveView
			document.body.removeEventListener \mouseup @onmouseupView
			removeEventListener \blur @onmouseupView
			m.redraw!

	oncontextmenuView: (event) !->
		unless os.contextMenuList
			@selEntries = []
		os.showContextMenu event,
			* text: "Kiểu hiển thị"
				icon: \grid-2
				submenu:
					* text: "Danh sách"
						icon: \circle-small if @viewMode is \list
						shown: not os.args.isDesktop
						onclick: !~>
							@viewMode = \list
					* text: "Biểu tượng"
						icon: \circle-small if @viewMode is \icon
						shown: not os.args.isDesktop
						onclick: !~>
							@viewMode = \icon
					* text: "Hiển thị các mục"
						icon: \check if @isShowDesktop
						shown: os.args.isDesktop
						onclick: !~>
							not= @isShowDesktop
			* text: "Sắp xếp theo"
				icon: \bars-sort
				submenu:
					* text: "Tên"
						icon: \circle-small if @sortBy is \name
						onclick: !~>
							@sortBy = \name
							@sortOrder = 1
							@sort!
					* text: "Ngày"
						icon: \circle-small if @sortBy is \mtime
						onclick: !~>
							@sortBy = \mtime
							@sortOrder = -1
							@sort!
					* text: "Loại"
						icon: \circle-small if @sortBy is \type
						onclick: !~>
							@sortBy = \type
							@sortOrder = 1
							@sort!
					* text: "Kích thước"
						icon: \circle-small if @sortBy is \size
						onclick: !~>
							@sortBy = \size
							@sortOrder = -1
							@sort!
					,,
					* text: "Tăng dần"
						icon: \circle-small if @sortOrder is 1
						onclick: !~>
							@sortOrder = 1
							@sort!
					* text: "Giảm dần"
						icon: \circle-small if @sortOrder is -1
						onclick: !~>
							@sortOrder = -1
							@sort!
			,,
			* text: "Làm mới"
				icon: \arrow-rotate-left
				onclick: !~>
					@reload!

	view: ->
		m \.App.column,
			unless os.args.isDesktop
				m \.col-0.row.gap-5.p-5,
					m InputGroup,
						class: "col-0"
						m Button,
							disabled: not @undo.canUndo
							icon: \arrow-left
							onclick: @onclickBack
						m Button,
							disabled: not @undo.canRedo
							icon: \arrow-right
							onclick: @onclickForward
						m Button,
							disabled: @path is \/
							icon: \arrow-up
							onclick: @onclickParent
					m InputGroup,
						class: "col"
						isForm: yes
						onsubmit: @onsubmitForm
						m TextInput,
							value: @tmpPath
							oninput: @oninputPath
						m Button,
							icon: \arrow-rotate-left
							onclick: @onclickReload
						m Button,
							icon: \arrow-turn-down-left
							type: \submit
			m \.col.relative.no-scroll.p-5,
				class: os.class do
					"pt-0": not os.args.isDesktop
					"text-white": os.args.isDesktop
				onmousedown: @onmousedownView
				oncontextmenu: @oncontextmenuView
				if @isShowDesktop
					if Array.isArray @entries
						switch @viewMode
						| \list
							m Table,
								class: "max-h-100"
								truncate: yes
								interactive: yes
								header:
									m \tr,
										m \th.col-6 "Tên"
										m \th.col-2 "Kích thước"
										m \th.col-4 "Ngày sửa đổi"
								@entries.map (entry) ~>
									m \tr.App__entry,
										key: entry.path
										class: os.class do
											"bg-blue-2 active": @selEntries.includes entry
										ondblclick: (event) !~>
											@ondblclickEntry entry, event
										oncontextmenu: (event) !~>
											@oncontextmenuEntry entry, event
										m \td.col-6,
											m Icon,
												class: "mr-4"
												name: entry.icon
											entry.name
										m \td.col-2,
											entry.isDir and \- or filesize entry.size
										m \td.col-4,
											dayjs entry.mtime .format "DD/MM/YYYY HH:mm"
						| \icon
							m \.grid.gap-2,
								style: os.style do
									gridTemplateColumns: "repeat(auto-fill,minmax(120px,1fr))"
									gridAutoRows: 80
								@entries.map (entry) ~>
									m \.column.center.around.rounded.p-4.bg-hover-light-3.text-center.App__entry,
										key: entry.path
										class: os.class do
											"bg-blue-2 active": @selEntries.includes entry
										ondblclick: (event) !~>
											@ondblclickEntry entry, event
										oncontextmenu: (event) !~>
											@oncontextmenuEntry entry, event
										m Icon,
											name: entry.icon
											size: 32
										m \.w-100.truncate,
											entry.name
						| \desktop
							m \.grid.flow-column.gap-3.h-100,
								style: os.style do
									gridTemplateRows: "repeat(auto-fill,minmax(80px,1fr))"
									gridAutoColumns: 120
								@entries.map (entry) ~>
									m \.column.center.around.rounded.p-4.bg-hover-dark-1-25.text-center.App__entry,
										key: entry.path
										class: os.class do
											"bg-blue-3-50 active": @selEntries.includes entry
										ondblclick: (event) !~>
											@ondblclickEntry entry, event
										oncontextmenu: (event) !~>
											@oncontextmenuEntry entry, event
										m Icon,
											name: entry.icon
											size: 32
										m \.w-100.truncate,
											entry.name
					else
						m \p "Mục không tồn tại"
				if @selector?moving
					m \.absolute.border.border-blue-4.rounded.bg-blue-4-25.no-events,
						style: os.style do
							left: @selector.x1 - @selector.offsetX
							top: @selector.y1 - @selector.offsetY
							width: @selector.x2 - @selector.x1
							height: @selector.y2 - @selector.y1
