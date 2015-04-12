children = (node) ->
	node.slice(1)

dfs = (node, callback) ->
	if node
		unless callback(node) is false
			for c in children(node)
				dfs c, callback

class Anonymizer
	constructor: ->

	_index: (x) -> if @needInfo then x + 1 else x

	_addInfo: (x) -> if @needInfo then x.unshift({}) else x

	_anonymizeValue: (tree, type, value, options) ->
		dfs tree, (n) =>
			if n instanceof Array
				if n?[@_index(0)] is type
					n[@_index(1)] = value
					if options?.trim
						n.splice(@_index(1) + 1, n.length)
				return true
			else 
				return false

	anonymize: (tree, type, needInfo) ->
		@needInfo = !!needInfo
		switch type
			when 'number'    then @_anonymizeValue tree, type, 0
			when 'string'    then @_anonymizeValue tree, type, '"?"'
			when 'selector'  
				ident = @_addInfo ['ident','x']
				newSelector = @_addInfo ['simpleselector', ident]
				@_anonymizeValue tree, 'selector', newSelector, {trim: true}


module.exports = -> new Anonymizer()