util    = require('util')
path    = require('path')
chalk   = require('chalk')

###*
# A base reporter from which all others inherit. Registers a listener on the
# passed inspector instance for tracking the number of matches found.
###
class BaseReporter

    constructor: (@_inspector, opts = {}) ->
        @_found = 0
        @_skipped = 0
        @_totalSize = 0
        @_thresholdTypeName = @_getThresholdTypeName(opts.thresholdType or 'char')
        @_registerListener()

    ###*
    # Helpers
    ###
    _pluralize : (count, text) -> 
        unless count is 1
            if text[-1..-1] is 'y'
                text[0..-2] + 'ies'
            else
                text + 's'
        else text
    _pluralizeE : (count, text) -> unless count is 1 then text + 'es' else text
    _getThresholdTypeName : (type) -> if type is 'char' then 'character' else type

    ###*
    # Registers a listener to the "match" event exposed by the Inspector instance.
    # Increments _found for each match emitted, and invokes the object's
    # _getOutput method, writing it to stdout.
    ###
    _registerListener: ->
        @_inspector.on 'match', (match) =>
            @_found++
            @_totalSize += match.duplicationSize
            process.stdout.write @_getOutput(match)
            
        @_inspector.on 'warning', (warn) =>
            @_skipped++
            process.stdout.write @_getWarning(warn)

    ###*
    # Registers a listener that prints a final summary outlining the number of
    # matches detected, as well as the number of files analyzed.
    ###
    _registerSummary: ->
        @_inspector.on 'end', =>
            found = ''
            total = ''
            numFiles = @_inspector.numFiles
            checked = "#{numFiles} #{@_pluralize(numFiles,'file')}"
            skipped = if @_skipped then " (#{@_skipped} #{@_pluralize(@_skipped,'file')} skipped)" else ''
            
            unless @_found
                found = chalk.black.bgGreen " No matches found across #{checked} "
            else
                found = chalk.white.bgRed " #{@_found} #{@_pluralizeE(@_found,'match')} found across #{checked} "
                total = chalk.white.bgRed "\n Total size: #{@_totalSize} #{@_pluralize(@_totalSize,@_thresholdTypeName)} "
            
            process.stdout.write '\n' + found + skipped + total + '\n'

    ###*
    # Accepts a diff object and returns a corresponding formatted diff string.
    # The object contains three keys: value, a string with possible newlines,
    # added, a boolean indicating if it were an addition, and removed, for if it
    # were removed from the src. The formatted diff is padded and uses "+" and "-"
    # for indicating the addition and removal of lines.
    ###
    _getFormattedDiff: (diff) ->
        output = ''
        diffLength = 0
        for chunk in diff
            lines = chunk.value.split('\n')
            if chunk.value.slice(-1) == '\n'
                lines = lines.slice(0, -1)
                
            diffLength += lines.length

            for line in lines
                if chunk.added
                    output += chalk.green("+   #{line}\n")
                else if chunk.removed
                    output += chalk.red("-   #{line}\n")
                else
                    output += "    #{line}\n"
                    
        return output

    ###*
    # Returns a string containing the path to the file in which the node is
    # located, as well as the lines on which the node exists.
    ###
    _getFormattedLocation: (node) ->
        filePath = node.loc.source
        # Convert any absolute paths to relative
        if filePath.charAt(0) is '/'
            filePath = path.relative(process.cwd(), filePath)
            
        filePath + ":#{node.loc.start},#{node.loc.end}"


module.exports = BaseReporter