_ = require 'underscore'
fs = require "fs"
path = require "path"
coffeekup = require "coffeecup"
async = require "async"

templates = 
	content: null
	post: null

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		@annex.addFileHandler /\.(coffee)$/, @processTemplate
		cb()
	processTemplate: (file, cb) =>
		switch file
			when "layout.coffee" then @_compileTemplate file, "content", cb
			when "post.coffee" then @_compileTemplate file, "post", cb
			else cb()
	layoutContent: (content, cb) ->
		return cb() unless templates.content
		process.nextTick ->
			cb null, (templates.content
				locals:
					content: content)
	layoutBlogPost: (post, meta, cb) ->
		return cb() unless templates.post
		process.nextTick ->
			return cb() unless templates.post
			locals =
				post: post
				nextPost: meta.nextPost
				prevPost: meta.prevPost
				isArchive: meta.archive
			cb null, (templates.post
				locals: locals)
	_compileTemplate: (file, target, cb) ->
		self = @
		fs.readFile (@annex.pathTo file), "utf8", (err, template) ->
			try
				templates[target] = coffeekup.compile template, 
					locals: true
					hardcode: {}
			catch e
				self.annex.log.warn "Error parsing layout #{file}"
				self.annex.log.warn e
			cb()
module.exports = (annex) ->
	return (new AnnexHandler annex)
