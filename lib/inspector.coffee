util         = require('util')
EventEmitter = require('events').EventEmitter
parse        = require('../parser/gonzales').cssToAST
fs           = require('fs')
beautify     = require('js-beautify').js_beautify

Match        = require('./match')
astToCSS     = require('./printer').astToCSS
anonymizer   = require('./anonymizer')()

###
# Inspector will walk through the given files, parse them, split into rulesets
# and generates hash for all of them. In case there is more than one ruleset with
# the same hash, they are considered a duplication and will be emited at the end
# of the process to a reporter.
###
class Inspector extends EventEmitter

    ###
    # Constructor creates a new Inspector. It expects array of filepaths and the
    # options. Default values are applied for the values that are only applicable 
    # to Inspector class (defaults for values used by Inspector and reporters
    # are being set on the higher level).  
    ###
    constructor: (@_filePaths = [], opts = {}) ->
        @_threshold     = if opts.threshold == 0 then 0 else opts.threshold or 50
        @_thresholdType = opts.thresholdType or 'char'
        @_ignoreValues  = opts.ignoreValues
        @_diff          = opts.diff
        @_skip          = opts.skip
        @_syntax        = opts.syntax
        @_anonymize     = opts.anonymize or []
        @_hash          = Object.create(null)
        @numFiles       = @_filePaths.length
        unless @_diff is 'none'
            @_fileContents = {}

    ###
    # Execute main action - walk through the files. In case of any parsing error
    # inspector decides to throw an error or just emit warning.
    ###
    run: ->
        opts = encoding: 'utf8'
        @emit 'start'

        for filePath in @_filePaths
            filePath = filePath.replace /\//g,'\\'
            contents = fs.readFileSync(filePath, opts)
            unless @_diff is 'none'
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

    ###
    # If the flag --syntax is used, we only parse to get the tree printed in the 
    # console. Otherwise parser gets 'needInfo' option to set location info for
    # each node. We are then anonymize nodes for all the given types and proceed 
    # to hash generation for each ruleset.
    ###
    _parse: (filePath, contents) ->
        if @_syntax
            syntaxTree = parse(css: contents, syntax: 'scss')
            console.log beautify JSON.stringify syntaxTree
        else
            syntaxTree = parse(css: contents, syntax: 'scss', needInfo: true)

            for type in @_anonymize
                anonymizer.anonymize(syntaxTree, type, true)

            @_walk syntaxTree, (rule) =>
                @_insert rule
                rule.loc.source = filePath

    ###
    # Emit 'match' event for all rulesets that had the same hash generated by the
    # Inspector. Diff is not generated if --diff flag is set to 'none'.
    ###
    _analyze: ->            
        for key of @_hash
            rules = @_hash[key]
            if rules?.length > 1
                match = new Match(rules)
                unless @_diff is 'none'
                    match.generateDiffs @_fileContents, @_diff
                @emit 'match', match

    ###
    # Hash generation for each ruleset. There are several types of nodes that can
    # represent block of rules, so we use only them and their children.
    ###
    _walk: (syntaxTree, fn) ->
        for ruleset in syntaxTree when ruleset[1] in ['ruleset','mediaquery','include','mixin']
            fn ruleset
            for block in ruleset when block[1] is 'block'
                @_walk block, fn

    ###
    # Generate hash and check if it does exceed threshold. Than push the ruleset
    # to the dictionary organized by hash.
    ###
    _insert: (rule) ->
        key = @_getHashKey(rule)

        if @_doesExceedThreshold key, rule
            @_hash[key] = []  unless @_hash[key]
            @_hash[key].push rule

    ###
    # Choose a method and calculate the size of duplication. 
    ###
    _doesExceedThreshold: (hash, syntaxTree) ->
        if @_thresholdType is 'char'
            hash.length >= @_threshold
        else if @_thresholdType is 'token'
            tokensLength = parse(css: hash, syntax: 'scss', needInfo: true, sizeOnly: true)
            tokensLength >= @_threshold
        else if @_thresholdType is 'property'
            propertiesLength = JSON.stringify(syntaxTree).match(/"declaration",\[\{[^\}]+\},"property"/g)?.length
            propertiesLength >= @_threshold
        else 
            throw new Error('Unknown type of element to apply threshold')

    ###
    # Generate hash by printing part of the syntax tree back into the source code.
    # We use modified printer that omits comments, minifies whitespaces and sorts
    # the selectors and rules.
    ###
    _getHashKey: (ruleset) -> 
        minCss = astToCSS({ ast:ruleset, syntax:'scss' })
        ruleset.type = 'ruleset'
        ruleset.loc =
            start: ruleset[0].ln
            end  : ruleset[0].end?.ln
        return minCss

module.exports = Inspector