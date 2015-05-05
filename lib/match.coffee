diff    = require('diff')
strip   = require('strip-indent')

###*
# Creates a new Match, consisting of an array of nodes. If generated, an
# instance also contains an array of diffs created with diff.
###
class Match

    constructor: (@nodes, @duplicationSize) ->
        @diffs = []

    ###*
    # Uses diff to generate line-based diffs for the nodes, given an object
    # mapping source file paths to their contents. If a match contains multiple
    # nodes, 2-way diffs are generated for each against the first node in the
    # array. The diffs are pushed into the diffs array in the same order as
    # the nodes.
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
    ###
    _getMethod : (diffType) ->
        if diffType is 'css'
            return diff.diffCss
        if diffType is 'lines'
            return diff.diffLines

        return null

    ###*
    # Returns a string containing the source lines for the supplied node.
    ###
    _getLines : (fileContents, node) ->
        lines = fileContents[node.loc.source]
        start = node.loc.start - 1
        end = node.loc.end
        strip lines.slice(start, end).join('\n')


module.exports = Match