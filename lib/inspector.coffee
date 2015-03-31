util         = require('util')
EventEmitter = require('events').EventEmitter
parse        = require('../parser/gonzales').cssToAST
fs           = require('fs')

Match        = require('./match')
astToCSS     = require('./css').astToCSS


class Inspector extends EventEmitter

    constructor: (@_filePaths = [], opts = {}) ->
        @_threshold     = opts.threshold or 15
        @_ignoreValues  = opts['ignore-values']
        @_diff          = opts.diff
        @_skip          = opts.skip
        @_syntax        = opts.syntax
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
            try
                @_parse filePath, contents
            catch err
                if @_skip
                    @numFiles--
                    @emit 'warning', 
                        message: 'Cannot parse file'
                        path: filePath
                        error: err
                else
                    throw err

        unless @_syntax
            @_analyze()
            @emit 'end'


    _parse: (filePath, contents) ->
        syntaxTree = parse(css: contents, syntax: 'scss', needInfo: true)

        if @_syntax
            console.log syntaxTree

        else
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
        structure = astToCSS({ ast:ruleset, syntax:'scss' }) 
        ruleset.type = 'ruleset'
        ruleset.pos = "(#{ruleset[0].ln}, #{ruleset[0].end?.ln})"
        ruleset.loc =
            start: {line: ruleset[0].ln}
            end  : {line: ruleset[0].end?.ln}
        return structure


module.exports = Inspector