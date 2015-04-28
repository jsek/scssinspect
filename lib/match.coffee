diff    = require('diff')
strip   = require('strip-indent')

###*
# Creates a new Match, consisting of an array of nodes. If generated, an
# instance also contains an array of diffs created with diff.
###
class Match

    ###*
    # @constructor
    #
    # @param {Node[]} nodes An array of matching nodes
    ###
    constructor: (@nodes, diffType) ->
        @diffs = []
        @duplicationSize = Math.max.apply(null, n.size for n in @nodes)

    ###*
    # Uses diff to generate line-based diffs for the nodes, given an object
    # mapping source file paths to their contents. If a match contains multiple
    # nodes, 2-way diffs are generated for each against the first node in the
    # array. The diffs are pushed into the diffs array in the same order as
    # the nodes.
    #
    # @param {object} fileContents The file paths and their contents
    ###
    generateDiffs : (fileContents, diffType) ->
        base = @_getLines(fileContents, @nodes[0])
        method = @_getMethod(diffType)

        if typeof method is 'function'
            for node in @nodes[1..]
                curr = @_getLines(fileContents, node)
                @diffs.push @_getMethod(diffType)(base, curr)

    ###*
    # Returns a method from diff object for the given type.
    #
    # @param   {String} diffType The type of diff to show
    # @returns {function} The method to diff the code
    ###
    _getMethod : (diffType) ->
        if diffType is 'css'
            return diff.diffCss
        if diffType is 'lines'
            return diff.diffLines

        return null

    ###*
    # Returns a string containing the source lines for the supplied node.
    #
    # @param   {object} fileContents The file paths and their contents
    # @param   {Node}   node         The node for which to extract its lines
    # @returns {String} The lines corresponding to the node's body
    ###
    _getLines : (fileContents, node) ->
        lines = fileContents[node.loc.source]
        start = node.loc.start - 1
        end = node.loc.end
        strip lines.slice(start, end).join('\n')


module.exports = Match