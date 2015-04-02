expect      = require('expect.js')
fs          = require('fs')
    
parse       = require('../parser/gonzales').cssToAST
fixtures    = require('./fixtures')
Match       = require('../lib/match')

describe 'Match', ->

    getFixture = (file) ->
        content = fs.readFileSync(file, encoding: 'utf8').replace(/\r\n/g,'\n')
        
        contents = {}
        contents[file] = content.split('\n')
        
        return { contents }


    describe 'constructor', ->
        it 'accepts an array of nodes, storing them at match.nodes', ->
            mockNodes = [
                { type: 'FunctionDeclaration' }
                { type: 'Literal' }
            ]
            match = new Match(mockNodes)
            expect(match.nodes).to.be mockNodes
            
        it 'initializes the object with an empty array for match.diffs', ->
            match = new Match([])
            expect(match.diffs).to.eql []
        
        
    describe 'generateDiffs', ->
    
        it 'uses jsdiff to generate a diff of two different rules', ->
            file = fixtures['intersection-diff']
            fixture = getFixture(file)
            rules = [
                { loc: { start : { line:  2 }, end : { line:  6 }, source: file } }
                { loc: { start : { line: 10 }, end : { line: 13 }, source: file } }
            ]
            match = new Match(rules)
            match.generateDiffs fixture.contents, 'lines'
            expect(match.diffs).to.eql [ [
                {
                    value: '''
                    .b, .a {
                    
                    '''
                    count: 1
                    added: true
                    removed: undefined
                }
                {
                    value: '''
                    .a, .b {
                    
                    '''
                    count: 1
                    added: undefined
                    removed: true
                }
                {
                    value: '''
                    .
                        border: 2px solid red;
                        color: blue;
                    
                    '''.slice(2)
                    count: 2
                }
                {
                    value: '''
                    .
                        z-index: 11; }
                    '''.slice(2)
                    count: 1
                    added: true
                    removed: undefined
                }
                {
                    value: '''
                    .
                        z-index: 11;
                    }
                    '''.slice(2)
                    count: 2
                    added: undefined
                    removed: true
                }
            ] ]

        it 'uses jsdiff to generate a diff of two identical rules', ->
            file = fixtures['intersection']
            fixture = getFixture(file)
            rules = [
                { loc: { start : { line:  2 }, end : { line:  6 }, source: file } }
                { loc: { start : { line: 10 }, end : { line: 14 }, source: file } }
            ]
            match = new Match(rules)
            match.generateDiffs fixture.contents, 'lines'
            expect(match.diffs).to.eql [ [
                {
                    value: '''
                    .sub-selector1, .sub-selector2 {
                        border: 2px solid red;
                        color: blue;
                        z-index: 11;
                    }
                    '''
                }
            ] ]


        it 'strips indentation to generate clean diffs', ->
            file = fixtures['indentation']
            fixture = getFixture(file)
            rules = [
                { loc: { start : { line: 1 }, end : { line: 3 }, source: file } }
                { loc: { start : { line: 5 }, end : { line: 6 }, source: file } }
            ]
            match = new Match(rules)
            match.generateDiffs fixture.contents, 'lines'
            expect(match.diffs).to.eql [ [
                {
                    value: '''
                    .sub-selector2, .sub-selector1 {
                    
                    '''
                    count: 1
                }
                {
                    value: '''
                    .
                        border: 2px solid red; }
                    '''.slice(2)
                    count: 1
                    added: true
                    removed: undefined
                }
                {
                    value: '''
                    .
                        border: 2px solid red;
                    }
                    '''.slice(2)
                    count: 2
                    added: undefined
                    removed: true
                }
            ] ]
