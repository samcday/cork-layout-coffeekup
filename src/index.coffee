_ = require 'underscore'
fs = require "fs"
path = require "path"
coffeekup = require "coffeecup"
async = require "async"

templates = 
	page: null
	post: null
	category: null
	archive: null

class AnnexHandler
	constructor: (@annex) ->
	init: (files, cb) ->
		@annex.addFileHandler /\.(coffee)$/, @processTemplate
		cb()
	processTemplate: (file, cb) =>
		switch file
			when "layout.coffee" then @_compileTemplate file, "page", cb
			when "post.coffee" then @_compileTemplate file, "post", cb
			when "category.coffee" then @_compileTemplate file, "category", cb
			when "archive.coffee" then @_compileTemplate file, "archive", cb
			else cb()
	layoutPage: (content, meta, cb) ->
		@_renderTemplate "page", { _meta: meta, content: content }, cb
	layoutBlogPost: (blog, post, meta, cb) ->
		[nextPost, prevPost] = blog.getNeighbours post.slug
		locals =
			blog: blog
			post: post
			nextPost: nextPost
			prevPost: prevPost
			isArchive: meta.archive
		@_renderTemplate "post", locals, cb
	layoutBlogCategory: (type, name, posts, cb) ->
		locals = 
			type: type
			name: name
			posts: posts
		@_renderTemplate "category", locals, cb
	layoutBlogArchive: (blog, page, posts, cb) ->
		locals = 
			blog: blog
			page: page
			totalPages: blog.numPages
			posts: posts
		@_renderTemplate "archive", locals, cb
	_renderTemplate: (name, locals, cb) ->
		return cb() unless templates[name]
		provided = 
			_: _
		try
			cb null, (templates[name] locals: _.extend {}, provided, locals)
		catch e
			@annex.log.warn "Error rendering template #{name}"
			@annex.log.error e
			cb()
	_compileTemplate: (file, target, cb) ->
		fs.readFile (@annex.pathTo file), "utf8", (err, template) =>
			try
				templates[target] = coffeekup.compile template, 
					locals: true
					hardcode: {}
			catch e
				@annex.log.warn "Error parsing layout #{file}"
				@annex.log.warn e
			cb()

module.exports = (annex) ->
	return (new AnnexHandler annex)
