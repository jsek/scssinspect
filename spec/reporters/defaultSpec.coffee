expect          = require('expect.js')

fixtures        = require('../fixtures')
helpers         = require('../helpers')
DefaultReporter = require('../../lib/reporters/default')
Inspector       = require('../../lib/inspector')

describe 'DefaultReporter', ->

    describe 'constructor', ->
    
        it 'accepts an inspector as an argument', ->
            inspector = new Inspector([ '' ])
            reporter = new DefaultReporter(inspector)
            expect(reporter._inspector).to.be inspector

    it 'prints the summary on end', ->
        helpers.captureOutput()
        helpers.safeTestOutput Inspector, DefaultReporter, 'no-match', (o) ->
            expect(o).to.be '\n No matches found across 1 file\n'

    describe 'given a match', ->
    
        beforeEach ->
            helpers.captureOutput()
            
        it 'prints the number of instances, and their location', ->
            file = fixtures.intersection
            helpers.safeTestOutput Inspector, DefaultReporter, 'intersection', {diff: false, ignoreSummary: true}, (o) ->
                expect(o).to.be """

                Match - 2 instances
                #{file}:2,6
                #{file}:10,14

                """

        it 'prints the diffs if enabled', ->
            file = fixtures.intersection
            helpers.safeTestOutput Inspector, DefaultReporter, 'intersection', {diff: true, ignoreSummary: true}, (o) ->
                expect(o).to.be """

                Match - 2 instances
                #{file}:2,6
                #{file}:10,14

                - #{file}:2,6
                + #{file}:10,14
                    .sub-selector1, .sub-selector2 {
                        border: 2px solid red;
                        color: blue;
                        z-index: 11;
                    }

                """