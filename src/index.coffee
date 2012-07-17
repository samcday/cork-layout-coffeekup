fs = require "fs"
path = require "path"
coffeekup = require "coffeecup"

layoutData = null

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		@files = files
		cb()
	processFile: (file, cb) ->
		if file is "index.coffee"
			fs.readFile (path.join @annex.root, file), "utf8", (err, contents) ->
				layoutData = contents
				console.log layoutData
				cb()
			return
		cb()

module.exports = (annex) ->
	return (new AnnexHandler annex)
