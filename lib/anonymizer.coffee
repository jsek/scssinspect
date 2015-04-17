children = (node) ->
	node.slice(1)

dfs = (node, callback) ->
	if node
		unless callback(node) is false
			for child in children(node)
				dfs child, callback

class Anonymizer
	constructor: ->

	_index: (x) -> if @needInfo then x + 1 else x

	_addInfo: (x) -> 
		if @needInfo then x.unshift({})
		return x

	_anonymizeValue: (tree, type, value, options) ->
		dfs tree, (node) =>
			@_onMatchedByType node, type, (n) => 
				n[@_index(1)] = value
				if options?.trim
					n.splice(@_index(1) + 1, n.length)

	_replaceNode: (tree, type, value, options) ->
		dfs tree, (node) =>
			@_onMatchedByType node, type, (n) => 
				n.splice.apply(n, [0, n.length].concat value)

	_onMatchedByType: (node, type, action) ->
		if node instanceof Array
				if node?[@_index(0)] is type
					action(node)
				return true
			else
				return false

	_fakeNode: -> @_addInfo ['ident','x']

	anonymize: (tree, type, needInfo) ->
		@needInfo = !!needInfo
		switch type
			when 'base64'
				@_anonymizeValue tree, type, 'data:image/png;base64,abc'
			when 'class'
				@_anonymizeValue tree, type, @_fakeNode()
			when 'interpolation'
				@_replaceNode tree, 'interpolatedVariable', @_fakeNode()
			when 'number'
				@_anonymizeValue tree, type, 0
			when 'selector'
				newSelector = @_addInfo ['simpleselector', @_fakeNode()]
				@_anonymizeValue tree, type, newSelector, {trim: true}
			when 'string'
				@_anonymizeValue tree, type, '"?"'
			when 'value'
				@_anonymizeValue tree, type, @_fakeNode(), {trim:true}
			when 'variable'
				@_anonymizeValue tree, type, @_fakeNode()

module.exports = -> new Anonymizer()