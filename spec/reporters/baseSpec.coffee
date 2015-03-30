expect       = require('expect.js')

fixtures     = require('../fixtures')
helpers      = require('../helpers')
BaseReporter = require('../../lib/reporters/base')
Inspector    = require('../../lib/inspector')

# A simple TestReporter for testing the BaseReporter
class TestReporter extends BaseReporter
    constructor: (inspector) ->
        super inspector
        @_registerSummary()
    _getOutput: (match) ->

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
            helpers.safeTestOutput Inspector, TestReporter, 'intersection', (o) -> 
                expect(o).to.not.be null
            
        it 'prints the correct results if no matches were found', ->
            helpers.safeTestOutput Inspector, TestReporter, 'no-match', (o) -> 
                expect(o).to.be '\n No matches found across 1 file\n'
            
        it 'prints the correct results if matches were found', ->
            helpers.safeTestOutput Inspector, TestReporter, 'intersection', (o) -> 
                expect(o).to.be '\n 1 match found across 1 file\n'