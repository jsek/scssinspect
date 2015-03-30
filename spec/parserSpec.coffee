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

    it 'should parse stylesheet with import statements without exception', ->
        file = fixtures['import-strings']
        helpers.safeTestOutput Inspector, DefaultReporter, 'import-strings', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 


    it 'should parse interpolation in calc without exception', ->
        file = fixtures['interpolation-calc']
        helpers.safeTestOutput Inspector, DefaultReporter, 'interpolation-calc', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 


    it 'should parse functions inside interpolation without exception', ->
        file = fixtures['interpolation-functions']
        helpers.safeTestOutput Inspector, DefaultReporter, 'interpolation-functions', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 


    xit 'should parse media-queries without exception', ->
        file = fixtures['media-queries']
        helpers.safeTestOutput Inspector, DefaultReporter, 'media-queries', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 


    xit 'should parse negative values without exception', ->
        file = fixtures['negative-values']
        helpers.safeTestOutput Inspector, DefaultReporter, 'negative-values', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 
            
            
    it 'should parse nested functions without exception', ->
        file = fixtures['nested-functions']
        helpers.safeTestOutput Inspector, DefaultReporter, 'nested-functions', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 

            
    xit 'should parse expressions inside url() without exception', ->
        file = fixtures['expression-in-url']
        helpers.safeTestOutput Inspector, DefaultReporter, 'expression-in-url', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 

            
    it 'should parse variables assignment without exception', ->
        file = fixtures['media-queries']
        helpers.safeTestOutput Inspector, DefaultReporter, 'variables', {diff: false, ignoreSummary: true}, (o) ->
            expect(o).to.be '' 
