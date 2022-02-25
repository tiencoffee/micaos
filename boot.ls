Paths = await (await fetch \paths.json)json!

[bothCode, bothStyl, mainCode, mainStyl, bothComp, mainComp] = await Promise.all [
	fetch \code/both/code.ls .then (.text!)
	fetch \code/both/styl.styl .then (.text!)
	fetch \code/main/code.ls .then (.text!)
	fetch \code/main/styl.styl .then (.text!)
	Promise.all Paths"comp/both/*"map (path) ~>
		fetch path .then (.text!)
	Promise.all Paths"comp/main/*"map (path) ~>
		fetch path .then (.text!)
]

bothComp *= \\n
mainComp = bothComp + mainComp * \\n

styl = bothStyl.replace /(^\t+)?\/\* (.+?) \*\//gm (, tab, name) ~>
	val = switch name
		| \styl => mainStyl
	val .= replace /^(?=.)/gm \\t * tab.length if tab
	val
try
	css = stylus.render styl, compress: yes
catch e
	console.error e.stack
	return
el = document.createElement \style
el.textContent = css
document.head.appendChild el

code = bothCode.replace /(^\t+)?\/\* (.+?) \*\//gm (, tab, name) ~>
	val = switch name
		| \comp => mainComp
		| \code => mainCode
	val .= replace /^(?=.)/gm \\t * tab.length if tab
	val
js = livescript.compile code
eval js
