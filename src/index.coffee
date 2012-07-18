fs = require "fs"
path = require "path"
coffeekup = require "coffeecup"

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		@files = files
		cb()
	processFile: (file, cb) ->
		cb()
	layoutContent: (content, cb) ->
		fs.readFile (@annex.pathTo "layout.coffee"), "utf8", (err, layout) ->
			console.log coffeekup.render layout, content: content
			cb null, coffeekup.render layout, content: content

module.exports = (annex) ->
	return (new AnnexHandler annex)
