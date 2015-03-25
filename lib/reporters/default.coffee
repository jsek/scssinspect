util         = require('util')
chalk        = require('chalk')
BaseReporter = require('./base')

###*
# The default reporter, which displays both file and line information for
# each given match. If enabled via opts.diff, corresponding diffs are also
# printed.
###
class DefaultReporter extends BaseReporter

    ###*
    # @constructor
    #
    # @param {Inspector} inspector The instance on which to register its listeners
    # @param {object}    opts      Options to set for the reporter
    ###
    constructor: (inspector, opts = {}) ->
        super inspector, opts
        @_diff = opts.diff
        @_registerSummary()

    ###*
    # Returns the string output to print for the given reporter. The string
    # contains the number of instances associated with the match and the files
    # and lines involved. If diffs are enabled, 2-way diffs are formatted and
    # included.
    #
    # @private
    #
    # @param   {Match}  match The inspector match to output
    # @returns {string} The formatted output
    ###
    _getOutput: (match) ->
        nodes = match.nodes
        output = '\n' + chalk.bold("Match - #{nodes.length} istances\n")

        for node in nodes
            output += "#{node.file} #{node.pos}\n"
        #    source = @_getFormattedLocation(node) + '\n'
        #    output += if @_diff then chalk.bold(source) else source
        #    
        if @_diff
            output += "\t #{node.structure}\n"
        #    for diff in match.diffs
        #        files = "- #{@_getFormattedLocation(nodes[0])} \n+ #{@_getFormattedLocation(nodes[i + 1])}\n"
        #        output += "\n
        #            #{chalk.grey(files)}
        #            #{@_getFormattedDiff(diff)}
        #        "
        return output


module.exports = DefaultReporter