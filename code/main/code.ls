App =
	oninit: !->
		@textInputValue = "Hoa sứ nhà nàng"
		@numberInputValue = 16
		@passwordInputValue = \oiBạnƠi21#@
		@checkboxChecked = yes
		@radioChecked = no
		@sliderValue = 1.3
		@sliderValue2 = 3
		@tabsTabId = 1
		@popoverIsOpen1 = no
		@popoverIsOpen2 = yes
		@popoverIsOpen3 = no
		@popoverIsOpen4 = no
		@pkms =
			* name: "Mewtwo"
				no: 150
				icon: \https://serebii.net/pokedex-swsh/icon/150.png
				type: "Psychic"
				value: \mewtwo
			* name: "Farfetch'd"
				no: 83
				icon: \https://serebii.net/pokedex-swsh/icon/083.png
				type: "Normal / Flying"
				value: \farfetchd
			* name: "Sobble"
				no: 816
				icon: \https://serebii.net/pokedex-swsh/icon/816.png
				type: "Water"
				value: \sobble
			* name: "Rhyperior"
				no: 464
				icon: \https://serebii.net/pokedex-swsh/icon/464.png
				type: "Ground / Rock"
				value: \rhyperior
			* name: "Tapu Koko"
				no: 785
				icon: \https://serebii.net/pokedex-swsh/icon/785.png
				type: "Electric / Fairy"
				value: \tapukoko
			* name: "Arbok"
				no: 24
				icon: \https://serebii.net/pokedex-swsh/icon/024.png
				type: "Poison"
				value: \arbok
			* name: "Pyroar"
				no: 668
				icon: \https://serebii.net/pokedex-swsh/icon/668.png
				type: "Fire / Normal"
				value: \pyroar
		@selectValue = 2022.02
		@selectItems =
			* text: "Thay tôi yêu cô ấy"
				icon: \mug-hot
				value: \thay-toi-yeu-co-ay
			* text: "Có như không có"
				value: 12
			* header: "Nhạc trẻ"
			* text: "Người lạ ơi xin cho tôi mượn bờ vai, tựa đầu gục ngã vì mỏi mệt quá"
			* text: "Nỗi buồn mang tên yêu xa"
				icon: 3237429
				value: 2022.02
			2022.02
			no
			null
			-Infinity
			[\A \b \~]
			Math
			,,
			* text: "Gõ cửa trái tim"
				icon: \door-closed
				value: [yes 60]
			"Văn bản thô..."
			* value: \mewtwo
			* icon: \icons
				value: "Only icons"
		@menuItems =
			* text: "Mở"
				color: \blue
			* text: "Mở bằng..."
			,,
			* text: "Công cụ"
				submenu:
					* text: "Bút"
						icon: \marker
					* text: "Chọn màu"
						icon: \palette
					* text: "Đổ màu"
						icon: \fill
					,,
					* text: "Căn chỉnh"
						color: \green
						submenu:
							* text: "Trái"
								icon: \align-left
							* text: "Giữa"
								icon: \align-center
							* text: "Phải"
								icon: \align-right
					* text: "Xóa hết"
						icon: \eraser
						disabled: yes
						color: \red
			* text: "Đoạn văn"
				icon: \paragraph
				label: "F3"
				submenu:
					* text: "Thời đại nào cũng có các phong tục, tín ngưỡng và truyền thống riêng biệt."
			* text: "Hiện các mục"
			,,
			* text: "Các ứng dụng khác"
				icon: 831276
				submenu:
					* header: "Đã cài đặt"
					* text: "Google"
						icon: 300221
						submenu:
							* text: "Youtube"
								icon: 1384060
					* text: "Facebook"
						icon: 733547
						submenu:
							* text: "Messenger"
								icon: 889101
							* text: "Instagram"
								icon: 2111463
					* header: "Khác"
					* text: "Tiktok"
						icon: 3046121
					* text: "LINE"
						icon: 124027
			,,
			* header: "Sửa đổi"
			* text: "Sao chép"
				icon: \clone
				label: "Ctrl+C"
			* text: "Dán"
				icon: \clipboard
				disabled: yes
				label: "Shift+Insert"
			,,
			* text: "Xóa"
				icon: \trash
				color: \red
				label: "Delete"

	view: ->
		m \.App,
			style:
				padding: \16px
			if @checkboxChecked
				m \style,
					".App > * {margin: 8px}"
			m \p Date.now!
			m Progress,
				value: 0.4
			m Progress,
				color: \red
				value: 0.65
			m Progress,
				color: \yellow
			m Progress,
				color: \green
				value: 0.65
				max: 2.5
			m Progress,
				color: \blue
				value: Math.random!
			m Spinner
			m Spinner,
				color: \blue
				value: Math.random!
			m Icon,
				name: \trash-alt
			m Icon,
				name: \far:times
			m Icon,
				name: \fad:photo-film-music
			m Icon,
				name: 742751
			m Button,
				onclick: !~>
				"Now"
			m Button,
				color: \blue
				"Blue"
			m Button,
				color: \red
				"Red"
			m Button,
				disabled: yes
				"Disabled"
			m Button,
				disabled: yes
				color: \red
				"Disabled"
			m Button,
				basic: yes
				"Basic"
			m Button,
				basic: yes
				color: \blue
				"Basic"
			m Button,
				basic: yes
				color: \red
				"Basic"
			m Button,
				disabled: yes
				basic: yes
				"Basic"
			m Button,
				disabled: yes
				basic: yes
				color: \blue
				"Basic"
			m Button,
				icon: \home
				"Home"
			m TextInput,
				value: @textInputValue
				oninput: (event) !~>
					@textInputValue = event.target.value
			m TextInput,
				disabled: yes
				icon: \flower
				value: @textInputValue
			m NumberInput,
				value: @numberInputValue
				oninput: (val) !~>
					@numberInputValue = val
			m PasswordInput,
				value: @passwordInputValue
				oninput: (val) !~>
					@passwordInputValue = val
			m Popover,
				isOpen: @popoverIsOpen1
				oninteraction: (@popoverIsOpen1) !~>
				content: ~>
					m \.p-4,
						m \h3 "Đây là popover 1 nè mọi người ơi"
						m Popover,
							isOpen: @popoverIsOpen2
							oninteraction: (@popoverIsOpen2) !~>
							content:
								m \.p-5,
									"Na + Cl -> NaCl2 adjaijw diajid"
									m \br
									m \small Math.random!
									m Popover,
										content: ~>
											m \.p-4,
												m Popover,
													isOpen: @popoverIsOpen4
													oninteraction: (@popoverIsOpen4) !~>
													content:
														m \.p-4,
															m \p "Nhập số cứt cần mua:"
															m PasswordInput
													m \span "Bấm vô đây!"
												m \br
												m Select,
													items: @selectItems
													value: @selectValue
													oninput: (@selectValue) !~>
												m \br
												"Gõ cửa trái tim, van em được vào. Dù tình xót đau, chung thân huyệt đào."
												m \br
												"Ngủ vùi với chiêm bao, nỗi niềm mắt xanh xao..."
										m Button,
											color: \yellow
											icon: \music
							m Button,
								basic: yes
								color: \green
								icon: \star
								"Mở popover 2"
				m Button,
					"Mở popover"
			m Checkbox,
				checked: @checkboxChecked
				text: "Đã đọc"
				oninput: (event) !~>
					@checkboxChecked = event.target.checked
			m Switch,
				checked: @checkboxChecked
				text: @checkboxChecked and "Bật" or "Tắt"
				oninput: (event) !~>
					@checkboxChecked = event.target.checked
			m Radio,
				checked: @radioChecked
				text: "Radio"
				oninput: (event) !~>
					@radioChecked = event.target.checked
			m Slider,
				min: -1.3
				max: 11.67
				step: 2.08
				value: @sliderValue
				oninput: (@sliderValue) !~>
			m Slider,
				value: @sliderValue2
				oninput: (@sliderValue2) !~>
			m Slider,
				min: 3.2
				labelStep: 1.2
				vertical: yes
				value: @sliderValue
				oninput: (@sliderValue) !~>
			m Select,
				items: @selectItems
				value: @selectValue
				oninput: (@selectValue) !~>
			m Menu,
				items: @menuItems
			m Table,
				style:
					height: 160
				bordered: yes
				striped: yes
				interactive: yes
				header:
					m \tr,
						m \th "Icon"
						m \th "#"
						m \th "Tên"
						m \th "Hệ"
				body: ~>
					@pkms.map (pkm) ~>
						m \tr,
							m \td,
								m Icon,
									name: pkm.icon
							m \td pkm.no
							m \td pkm.name
							m \td pkm.type
			m Tabs,
				vertical: @checkboxChecked
				tabId: @tabsTabId
				onchange: (tabId) !~>
					@tabsTabId = tabId
				tabs:
					* title: "Raikou"
						icon: \https://serebii.net/pokedex-swsh/icon/243.png
						panel: ~>
							m \div,
								"Raikou là hiện thân của tốc độ ánh chớp. Tiếng gầm của thần khiến sóng điện lan tỏa khắp không khí và trời đất rung chuyển, tựa như khi sấm sét giáng xuống vậy."
					* title: "Entei"
						icon: \https://serebii.net/pokedex-swsh/icon/244.png
						panel: ~>
							m \div,
								"Entei là hiện thân của nhiệt huyết dung nham. Theo lời kể, thần được sinh ra từ núi lửa tuôn trào, và làm chủ ngọn lửa có khả năng thiêu rụi tất thảy."
					* title: "Suicune"
						icon: \https://serebii.net/pokedex-swsh/icon/245.png
						panel: ~>
							m \div,
								"Suicune là hiện thân của suối nguồn trắc ẩn. Thần sở hữu quyền năng thanh tẩy nước bẩn, khoan thai rong ruổi khắp đó đây."
			m \blockquote "Do Trái đất mà chúng ta đang sống là khối cầu, sức hút trọng lực của nó giống nhau ở mọi nơi trên bề mặt, điều này có nghĩa chừng nào bạn còn ở trên bề mặt phẳng, bạn sẽ đứng thẳng và cao. Nhưng bạn nghĩ điều gì sẽ xảy ra nếu bạn làm lệch phân bố trọng lực? Bạn có muốn sống ở rìa Trái đất? Hãy chọn một mặt. Giờ thì Trái đất có 6 mặt, nhưng không có mặt nào thú vị cả. Đó là bởi dù đi tới bất cứ đâu, bạn cũng sẽ cảm thấy như đang leo đồi dốc. Trên Trái đất hình vuông, trọng lực mạnh nhất ở trung tâm của mỗi mặt, do đó bạn càng đi xa khỏi tâm điểm, bạn càng cảm thấy rõ sức hút của nó. Bạn sẽ khó có thể cảm thấy đứng thẳng."
			m \code "<html>"
			m \kbd "Esc"
			m \kbd "A"
			m \pre,
				"""
					event.redraw = no
					unless item.submenu
					\tif typeof item.onclick is \\function
					\t\titem.onclick!
					\t@attrs.root.closeItem!
				"""
			m \ul,
				m \li "Chim"
				m \li "Bò sát"
					m \ul,
						m \li "Cá sấu"
						m \li "Rắn"
				m \li "Cá"
			m \h1 "Tiêu đề 1"
			m \h2 "Tiêu đề 2"
			m \h3 "Tiêu đề 3"
			m \h4 "Tiêu đề 4"
			m \h5 "Tiêu đề 5"
			m \h6 "Tiêu đề 6"
