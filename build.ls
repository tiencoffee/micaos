require! {
	\glob-concat
	"fs-extra": fs
}

Paths = {}

dir = \comp/both/*
Paths[dir] = []
for file in globConcat.sync dir
	Paths[dir]push file

dir = \comp/main/*
Paths[dir] = []
for file in globConcat.sync dir
	Paths[dir]push file

dir = \comp/user/*
Paths[dir] = []
for file in globConcat.sync dir
	Paths[dir]push file

fs.writeJsonSync \paths.json Paths, spaces: \\t
