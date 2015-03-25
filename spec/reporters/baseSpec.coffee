expect       = require('expect.js')
util         = require('util')
chalk        = require('chalk')
fixtures     = require('../fixtures')
helpers      = require('../helpers')
BaseReporter = require('../../lib/reporters/base.js')
Inspector    = require('../../lib/inspector.js')

# A simple TestReporter for testing the BaseReporter
class TestReporter extends BaseReporter
    contstructor: (inspector) ->
        super inspector
        @_registerSummary()

    _getOutput: ->

describe 'BaseReporter', ->

    describe 'constructor', ->
    
        it 'accepts an inspector as an argument', ->
            inspector = new Inspector([ '' ])
            reporter = new BaseReporter(inspector)
            expect(reporter._inspector).to.be inspector
            
        it 'registers a listener for the match event', ->
            inspector = new Inspector([ '' ])
            reporter = new BaseReporter(inspector)
            expect(inspector.listeners('match')).to.have.length 1
        
    describe 'given a match', ->
        beforeEach ->
            helpers.captureOutput()
            
        it 'increments the number found', ->
            inspector = new Inspector([ fixtures.intersection ], threshold: 3)
            reporter = new TestReporter(inspector)
            inspector.emit 'match', {}
            helpers.restoreOutput()
            expect(reporter._found).to.be 1
            
        it 'invokes _getOutput', ->
            inspector = new Inspector([ fixtures.intersection ], threshold: 3)
            reporter = new TestReporter(inspector)

            reporter._getOutput = (match) -> match

            inspector.emit 'match', 'invoked'
            helpers.restoreOutput()
            expect(helpers.getOutput()).to.be 'invoked'
        
    describe 'summary', ->
        beforeEach ->
            helpers.captureOutput()
            
        it 'can be printed on inspector end', ->
            inspector = new Inspector([ fixtures.intersection ])
            reporter = new TestReporter(inspector)
            inspector.run()
            helpers.restoreOutput()
            expect(helpers.getOutput()).to.not.be null
            
        xit 'prints the correct results if no matches were found', ->
            inspector = new Inspector([ fixtures.intersection ], threshold: 4)
            reporter = new TestReporter(inspector)
            inspector.run()
            helpers.restoreOutput()
            expect(helpers.getOutput()).to.be '\n No matches found across 1 files\n'
            
        xit 'prints the correct results if matches were found', ->
            inspector = new Inspector([ fixtures.intersection ], threshold: 3)
            reporter = new TestReporter(inspector)
            inspector.run()
            helpers.restoreOutput()
            expect(helpers.getOutput()).to.be '\n 1 matches found across 1 files\n'