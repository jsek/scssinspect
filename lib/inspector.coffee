_            = require('lodash')
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
        @_anonymize     = opts.anonymize or []
        @_language      = opts.language or 'scss'
        @_syntax        = opts.syntax
        @_skip          = opts.skip
        @_diff          = opts.diff
        @_ignoreValues  = opts.ignoreValues
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
    # each node and then we walk through syntax tree and group matching rulesets.
    ###
    _parse: (filePath, contents) ->
        if @_syntax
            syntaxTree = parse(css: contents, syntax: @_language)
            console.log beautify JSON.stringify syntaxTree
        else
            syntaxTree = parse(css: contents, syntax: @_language, needInfo: true)

            @_walk syntaxTree, (rule) =>
                @_insert rule
                @_setMetadata rule, filePath

    ###
    # Emit 'match' event for all rulesets that had the same hash generated by the
    # Inspector. Diff is not generated if --diff flag is set to 'none'.
    ###
    _analyze: ->            
        for key of @_hash
            rules = @_hash[key]
            if rules?.length > 1
            
                size = @_getMaxSize rules
                if size >= @_threshold
                
                    match = new Match(rules, size)
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
        ruleCopy = _.cloneDeep rule
        for type in @_anonymize
            anonymizer.anonymize(ruleCopy, type, true)
            
        key = @_tidy(ruleCopy) # now tidy anonymized ruleset
        
        @_hash[key] = []  unless @_hash[key]
        @_hash[key].push rule
        
    ###
    # Get the biggest size of duplication from all the rules 
    ###
    _getMaxSize: (rules) ->
        return Math.max.apply(null, @_getSize(@_tidy(r), r) for r in rules)

    ###
    # Choose a method and calculate the size of duplication. 
    ###
    _getSize: (hash, syntaxTree) ->
        if @_thresholdType is 'char'
            return hash.length
        else if @_thresholdType is 'token'
            return parse(css: hash, syntax: @_language, needInfo: true, sizeOnly: true)
        else if @_thresholdType is 'property'
            return JSON.stringify(syntaxTree).match(/"declaration",\[\{[^\}]+\},"property"/g)?.length
        else
            throw new Error('Unknown type of element to apply threshold')
            
    ###
    # Use modified printer that omits comments, minifies whitespaces and sorts
    # the selectors and rules.
    ###
    _tidy: (ruleset) -> 
        minCss = astToCSS({ ast:ruleset, syntax:@_language })
        return minCss
        
    ###
    # Set location and type for given ruleset 
    ###        
    _setMetadata: (ruleset, filePath) ->
        ruleset.type = 'ruleset'
        ruleset.loc =
            source  : filePath
            start   : ruleset[0].ln
            end     : ruleset[0].end?.ln

module.exports = Inspector