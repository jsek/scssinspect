fs          = require('fs')
parse       = require('acorn/acorn_loose').parse_dammit
chalk       = require('chalk')
fixtures    = require('./fixtures')

enabled = chalk.enabled
write   = process.stdout.write
parseCache = {}

class Helper

    constructor: () ->
        @output = ''


    captureOutput: ->
        chalk.enabled = false
        @output = ''
        process.stdout.write = (string) => if string then @output += string
        
        
    getOutput: -> @output
    
    
    restoreOutput: ->
        chalk.enabled = enabled
        process.stdout.write = write


    parse: (filePath) ->
        contents = undefined
        ast = undefined
        if parseCache[filePath]
            return parseCache[filePath]
        contents = fs.readFileSync(filePath, encoding: 'utf8')
        # Skip the parent 'Program' node
        ast = parse(contents,
            ecmaVersion: 6
            allowReturnOutsideFunction: true
            locations: true
            sourceFile: filePath).body
        parseCache[filePath] = ast
        return ast


    safeTestOutput: (Inspector, Reporter, filename, options, testFn) ->
        if typeof options is 'function'
            testFn = options 
            options = {}
        try
            inspector = new Inspector([ fixtures[filename] ], options)
            reporter = new Reporter(inspector, options)
            if options.ignoreSummary
                inspector.removeAllListeners 'end'
            inspector.run()
        catch
            throw new Error('Exception while executing spec')
        finally
            @restoreOutput()
            testFn @getOutput()


module.exports = new Helper()