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
		cb()
	processFile: (file, cb) =>
		switch file
			when "layout.coffee" then @_compileTemplate file, "content", cb
			when "post.coffee" then @_compileTemplate file, "post", cb
			else cb()
	layoutContent: (content, cb) ->
		process.nextTick ->
			cb null, (templates.content
				locals:
					content: content)
	layoutBlogPost: (post, nextPost, prevPost, content, cb) ->
		process.nextTick ->
			return cb() unless templates.post
			locals =
				post: (_.extend { content: content }, post)
				nextPost: nextPost
				prevPost: prevPost
			cb null, (templates.post
				locals: locals)
	_compileTemplate: (file, target, cb) ->
		fs.readFile (@annex.pathTo file), "utf8", (err, template) ->
			templates[target] = coffeekup.compile template, 
				locals: true
				hardcode: {}
			cb()
module.exports = (annex) ->
	return (new AnnexHandler annex)
