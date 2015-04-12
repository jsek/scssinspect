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

	_anonymizeValue: (tree, type, value) ->
		dfs tree, (n) =>
			if n?[@_index(0)] is type
				n[@_index(1)] = value
			else
				return true

	anonymize: (tree, type, needInfo) ->
		@needInfo = !!needInfo
		switch type
			when 'number' then @_anonymizeValue tree, type, 0
			when 'string' then @_anonymizeValue tree, type, '"?"'


module.exports = -> new Anonymizer()