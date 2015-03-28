util         = require('util')
EventEmitter = require('events').EventEmitter
parse        = require('./parser/gonzales-pe').cssToAST
fs           = require('fs')

Match        = require('./match')
astToCSS     = require('./css').astToCSS


class Inspector extends EventEmitter

    constructor: (@_filePaths = [], opts = {}) ->
        @_threshold     = opts.threshold or 15
        @_ignoreValues  = opts['ignore-values']
        @_diff          = opts.diff
        @_hash          = Object.create(null)
        @numFiles       = @_filePaths.length
        if @_diff
            @_fileContents = {}


    run: ->
        opts = encoding: 'utf8'
        @emit 'start'

        for filePath in @_filePaths
            filePath = filePath.replace /\//g,'\\'
            contents = fs.readFileSync(filePath, opts)
            if @_diff
                @_fileContents[filePath] = contents.split('\n')
            @_parse filePath, contents

        @_analyze()
        @emit 'end'


    _parse: (filePath, contents) ->
        syntaxTree = parse(css: contents, syntax: 'scss', needInfo: true)
        @_walk syntaxTree, (rule) => 
            @_insert rule
            rule.loc.source = filePath


    _analyze: ->
        for key of @_hash
            rules = @_hash[key]
            if rules?.length > 1
                match = new Match(rules)
                if @_diff
                    match.generateDiffs @_fileContents
                @emit 'match', match


    _walk: (syntaxTree, fn) ->
        for ruleset in syntaxTree when ruleset[1] is 'ruleset'
            fn ruleset
            for block in ruleset when block[1] is 'block'
                @_walk block, fn


    _insert: (rule) ->
        key = @_getHashKey(rule)
        unless @_hash[key]
            @_hash[key] = []
        # Assign the parent node to the key
        @_hash[key].push rule


    _getHashKey: (ruleset) -> 
        structure = astToCSS({ast:ruleset,syntax:'scss'}) 
        ruleset.pos = "(#{Math.round(ruleset[0].ln / 2)}, #{Math.round(ruleset[0].end?.ln / 2)})" # Why divide by 2? -> \r counts for line break
        ruleset.loc =
            start: {line: Math.round(ruleset[0].ln / 2)}
            end  : {line: Math.round(ruleset[0].end?.ln / 2)}
            # Why divide by 2? -> \r counts for line break
        return structure


module.exports = Inspector