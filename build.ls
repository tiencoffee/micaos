require! {
	\glob-concat
	"fs-extra": fs
}

Paths = {}

dirs =
	\comp/both/*
	\comp/main/*
	\comp/user/*
	\C/apps/*
	\C/imgs/**/*.*

for dir in dirs
	Paths[dir] = []
	for file in globConcat.sync dir
		Paths[dir]push \/ + file

fs.writeJsonSync \paths.json Paths, spaces: \\t
