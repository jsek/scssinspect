fs          = require('fs')
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