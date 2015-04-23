expect      = require('expect.js')
EventEmitter = require('events').EventEmitter

Inspector   = require('../lib/inspector.js')
Match       = require('../lib/match.js')
fixtures    = require('./fixtures')

describe 'Inspector', ->

    found = undefined # Used to test emitted events

    listener = (match) -> found.push match

    beforeEach -> found = []

    expectMatchCount = (fixture, opts, count) ->
        inspector = new Inspector([ fixture ], opts)
        inspector.on 'match', listener
        inspector.run()
        expect(found).to.have.length count
    
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
                threshold: 151
                
            inspector = new Inspector([], opts)
            expect(inspector._threshold).to.be opts.threshold
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
        expect(match.nodes[0].loc.start).to.eql 2
        expect(match.nodes[0].loc.end).to.eql 6
        
        expect(match.nodes[1].type).to.be 'ruleset'
        expect(match.nodes[1].loc.start).to.eql 10
        expect(match.nodes[1].loc.end).to.eql 14


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
        
    
    describe 'threshold (characters)', ->
    
        it 'matches rules if threshold is lower than rule size', ->
            opts =
                threshold: 70
                thresholdType: 'char'
            expectMatchCount fixtures.intersection, opts, 1
        
        it 'does not match rules that exceed threshold', ->
            opts =
                threshold: 80
                thresholdType: 'char'
            expectMatchCount fixtures.intersection, opts, 0
            
            
    describe 'threshold (tokens)', ->
            
        it 'matches rules if threshold is lower than rule size', ->
            opts =
                threshold: 30
                thresholdType: 'token'
            expectMatchCount fixtures.intersection, opts, 1
        
        it 'does not match rules that exceed threshold', ->
            opts =
                threshold: 40
                thresholdType: 'token'
            expectMatchCount fixtures.intersection, opts, 0
            

    describe 'threshold (properties)', ->
            
        it 'matches rules if threshold is lower than rule size', ->
            opts =
                threshold: 2
                thresholdType: 'property'
            expectMatchCount fixtures.intersection, opts, 1
        
        it 'does not match rules that exceed threshold', ->
            opts =
                threshold: 5
                thresholdType: 'property'
            expectMatchCount fixtures.intersection, opts, 0

    describe 'anonymize (number)', ->
            
        it 'matches rules if the only difference are numbers', ->
            opts =
                threshold: 0
                thresholdType: 'char'
                anonymize: ['number']
            expectMatchCount fixtures['anonymize-number'], opts, 1
        
        it 'does not match rules if the only difference are strings', ->
            opts =
                threshold: 0
                thresholdType: 'char'
                anonymize: ['number']
            expectMatchCount fixtures['anonymize-string'], opts, 0

    describe 'anonymize (string)', ->
        
        it 'matches rules if the only difference are strings', ->
            opts =
                threshold: 0
                thresholdType: 'char'
                anonymize: ['string']
            expectMatchCount fixtures['anonymize-string'], opts, 1

        it 'does not match rules if the only difference are numbers', ->
            opts =
                threshold: 0
                thresholdType: 'char'
                anonymize: ['string']
            expectMatchCount fixtures['anonymize-number'], opts, 0

    describe 'anonymize (selector)', ->
        
        it 'matches rules if the only difference are selectors', ->
            opts =
                threshold: 2
                thresholdType: 'property'
                anonymize: ['selector']
            expectMatchCount fixtures['anonymize-selector'], opts, 1

        it 'does not match rules if the only difference are selectors and anonymize option is not set for selectors', ->
            opts =
                threshold: 2
                thresholdType: 'property'
                anonymize: ['string']
            expectMatchCount fixtures['anonymize-selector'], opts, 0