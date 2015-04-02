expect      = require('expect.js')
EventEmitter = require('events').EventEmitter

Inspector   = require('../lib/inspector.js')
Match       = require('../lib/match.js')
fixtures    = require('./fixtures')

describe 'Inspector', ->

    found = undefined # Used to test emitted events

    listener = (match) -> found.push match

    beforeEach -> found = []

    
    describe 'constructor', ->

        it 'inherits from EventEmitter', ->
            expect(new Inspector).to.be.an EventEmitter

        it 'accepts an array of file paths', ->
            filePaths = [
                'path1.scss'
                'path2.scss'
            ]
            inspector = new Inspector(filePaths)
            expect(inspector._filePaths).to.be filePaths

        it 'accepts an options object', ->
            opts = 
                diff: 'none'
                
            inspector = new Inspector([], opts)
#            expect(inspector._threshold).to.be opts.threshold
            expect(inspector._diff).to.be opts.diff
            
            
    describe 'run', ->
        it 'emits a start event', ->
            emitted = undefined
            inspector = new Inspector([ fixtures.intersection ])
            inspector.on 'start', -> emitted = true
            inspector.run()
            expect(emitted).to.be true
        
        it 'emits an end event', ->
            emitted = undefined
            inspector = new Inspector([ fixtures.intersection ])
            inspector.on 'end', -> emitted = true
            inspector.run()
            expect(emitted).to.be true

        it 'emits the "match" event when a match is found', ->
            inspector = new Inspector([ fixtures.intersection ])
            inspector.on 'match', listener
            inspector.run()
            expect(found).to.have.length 1


    it 'can find an exact match between two rules', ->
        inspector = new Inspector([ fixtures.intersection ])
        inspector.on 'match', listener
        inspector.run()
        
        expect(found).to.have.length 1
        match = found[0]
        
        expect(match.nodes).to.have.length 2
        
        expect(match.nodes[0].type).to.be 'ruleset'
        expect(match.nodes[0].loc.start).to.eql {line: 2}
        expect(match.nodes[0].loc.end).to.eql {line: 6}
        
        expect(match.nodes[1].type).to.be 'ruleset'
        expect(match.nodes[1].loc.start).to.eql {line: 10}
        expect(match.nodes[1].loc.end).to.eql {line: 14}


    it 'includes a diff with the match, if enabled', ->
        opts =
            threshold: 0
            diff: 'lines'
        inspector = new Inspector([ fixtures['intersection-diff'] ], opts)
        inspector.on 'match', listener
        inspector.run()

        expect(found).to.have.length 1
        match = found[0]
        
        expect(match.nodes).to.have.length 2
        expect(match.diffs).to.have.length 1
        expect(match.diffs[0]).to.have.length 5