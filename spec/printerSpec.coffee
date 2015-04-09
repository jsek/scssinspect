expect          = require('expect.js')
fs              = require('fs')

fixtures        = require('./fixtures')
cssToAST        = require('../parser/gonzales').cssToAST
astToCSS        = require('../lib/css').astToCSS

describe 'Printer', ->

    expectPrinterOutput = (fixtureName) ->
        filePath    = fixtures[fixtureName].replace(/\//g,'\\')
        css         = fs.readFileSync(filePath, encoding: 'utf8')
        syntaxTree  = cssToAST(css: css, syntax: 'scss')
        text        = astToCSS(ast: syntaxTree, syntax: 'scss')
        goldText    = fs.readFileSync(filePath.replace(/\.scss$/,'.gold.scss'), encoding: 'utf8') 
        expect(text).to.be goldText

    it 'should print stylesheet without comments', ->
        expectPrinterOutput 'comments1'
        expectPrinterOutput 'comments2'

    it 'should print stylesheet with import statements', ->
        expectPrinterOutput 'import-strings'

    it 'should print interpolation in calc with short interpolated expression', ->
        expectPrinterOutput 'interpolation-calc'

    it 'should print interpolation in calc with longer interpolated expression', ->
        expectPrinterOutput 'interpolation-expression-in-calc'

    it 'should print functions inside interpolation', ->
        expectPrinterOutput 'interpolation-functions'

    xit 'should print media-queries', ->
        expectPrinterOutput 'media-queries'

    it 'should print negative values', ->
        expectPrinterOutput 'negative-values'
            
    it 'should print nested functions', ->
        expectPrinterOutput 'nested-functions'
            
    it 'should print expressions inside url()', ->
        expectPrinterOutput 'expression-in-url'
            
    it 'should print variables assignments', ->
        expectPrinterOutput 'variables'

    it 'should print base64 values', ->
        expectPrinterOutput 'base64'
