expect          = require('expect.js')
util            = require('util')
chalk           = require('chalk')
fixtures        = require('../fixtures')
helpers         = require('../helpers')
DefaultReporter = require('../../lib/reporters/default.js')
Inspector       = require('../../lib/inspector.js')

describe 'DefaultReporter', ->

    describe 'constructor', ->
    
        it 'accepts an inspector as an argument', ->
            inspector = new Inspector([ '' ])
            reporter = new DefaultReporter(inspector)
            expect(reporter._inspector).to.be inspector

    xit 'prints the summary on end', ->
        helpers.captureOutput()
        inspector = new Inspector([ fixtures.intersection ], threshold: 4)
        reporter = new DefaultReporter(inspector)
        inspector.run()
        helpers.restoreOutput()
        expect(helpers.getOutput()).to.be '\n No matches found across 1 files\n'

    xdescribe 'given a match', ->
    
        beforeEach ->
            helpers.captureOutput()
            
        it 'prints the number of instances, and their location', ->
            inspector = new Inspector([ fixtures.intersection ], {threshold: 3, diff: false})
            reporter = new DefaultReporter(inspector)
            inspector.removeAllListeners 'end'
            inspector.run()
            helpers.restoreOutput()
            expect(helpers.getOutput()).to.be '\nMatch - 2 instances\n
                spec/fixtures/intersection.scss:2,6\n
                spec/fixtures/intersection.scss:10,14\n'

        it 'prints the diffs if enabled', ->
            inspector = new Inspector([ fixtures.intersection ], diff: true)
            reporter = new DefaultReporter(inspector, diff: true)
            inspector.removeAllListeners 'end'
            inspector.run()
            helpers.restoreOutput()
            expect(helpers.getOutput()).to.be '''\nMatch - 2 instances\n
                spec/fixtures/intersection.scss:2,6\n
                spec/fixtures/intersection.scss:10,14\n\n
                spec/fixtures/intersection.scss:2,6\n
                + spec/fixtures/intersection.scss:10,14\n
                    .sub-selector1, .sub-selector2 {\n
                        border: 2px solid red;\n
                        color: blue;\n
                        z-index: 11;\n
                    }\n'''
