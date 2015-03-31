expect          = require('expect.js')

fixtures        = require('./fixtures')
helpers         = require('./helpers')
DefaultReporter = require('../lib/reporters/default')
Inspector       = require('../lib/inspector')

describe 'Parser', ->
    
    beforeEach ->
        helpers.captureOutput()

    it 'should parse stylesheet with comments correctly', ->
        file = fixtures.comments1
        helpers.safeTestOutput Inspector, DefaultReporter, 'comments1', {diff:false, ignoreSummary: true}, (o) ->
            expect(o).to.be """

            Match - 2 instances
            #{file}:1,5
            #{file}:12,16

            """

    it 'should parse stylesheet with comments inside ruleset correctly', ->
        file = fixtures.comments2
        helpers.safeTestOutput Inspector, DefaultReporter, 'comments2', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be """

            Match - 2 instances
            #{file}:1,5
            #{file}:7,15

            """

    expectNoParsingErrors = (fixtureName) ->
        helpers.safeTestOutput Inspector, DefaultReporter, fixtureName, {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be ''

    it 'should parse stylesheet with import statements without exception', ->
        expectNoParsingErrors 'import-strings'

    it 'should parse interpolation in calc without exception', ->
        expectNoParsingErrors 'interpolation-calc'

    it 'should parse functions inside interpolation without exception', ->
        expectNoParsingErrors 'interpolation-functions'

    it 'should parse media-queries without exception', ->
        expectNoParsingErrors 'media-queries'

    it 'should parse negative values without exception', ->
        expectNoParsingErrors 'negative-values'
            
    it 'should parse nested functions without exception', ->
        expectNoParsingErrors 'nested-functions'
            
    it 'should parse expressions inside url() without exception', ->
        expectNoParsingErrors 'expression-in-url'
            
    it 'should parse variables assignment without exception', ->
        expectNoParsingErrors 'variables'
