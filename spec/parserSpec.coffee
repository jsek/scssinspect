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
