util         = require('util')
BaseReporter = require('./base')

###*
# The HTML reporter, which generates markup. Reqiures scssinspect.css.
###
class HtmlReporter extends BaseReporter

    constructor: (inspector, opts = {}) ->
        super inspector, opts
        @_diff = opts.diff
        process.stdout.write """
            <!doctype html>
            <html>
            <head>
                <link rel='stylesheet' href='scssinspect.css' />
                <title>#{new Date()}</title>
            </head>
            <body>
            """
        @_registerSummary()

    _getOutput: (match) ->
        nodes = match.nodes
        output = """
            <header>Match - #{nodes.length} instances</header>
            """

        for node in nodes
            source = @_getFormattedLocation(node)
            output += "<h3>#{source.replace /\n/g,'<br>'}</h3>"

            
        if @_diff
            currentDiffIndex = 0
            
            for diff in match.diffs
                output += "<pre class='diff'>"
            
                currentDiffIndex++
                files = """
                    - #{@_getFormattedLocation(nodes[0])}
                    + #{@_getFormattedLocation(nodes[currentDiffIndex])}\n
                """
                output += "<code class='diff-files'>#{files}</code>" + @_getFormattedDiff(diff)
        
                output += "</pre>"
            
        return output

    _getWarning: (warn) ->
        return "<div class='warn'><b>WARNING<b>: #{warn.message} <span class='warn-file'>#{warn.path}</span><br> &gt; #{warn.error.message}</div>"

    _registerSummary: ->
        @_inspector.on 'end', =>
            found = ''
            numFiles = @_inspector.numFiles
            checked = "#{numFiles} #{@_pluralize(numFiles,'file')}"
            skipped = if @_skipped then "<span class='skipped'>#{@_skipped} #{@_pluralize(@_skipped,'file')} skipped</span>" else ''
            
            unless @_found
                found = "<span class='success'>No matches found across #{checked}</span>"
            else
                found = "<span class='failure'>#{@_found} #{@_pluralizeE(@_found,'match')} found across #{checked}</span>"
            
            process.stdout.write '<footer>' + found + skipped + '</footer>'
            process.stdout.write """
                </body>
                </html>
                """
            
    _getFormattedDiff: (diff) ->
        output = '\n'
        diffLength = 0
        for chunk in diff
            lines = chunk.value.split('\n')
            if chunk.value.slice(-1) == '\n'
                lines = lines.slice(0, -1)
            
            diffLength += lines.length
            if @_suppress and diffLength > @_suppress
                return "Diff suppressed as it exceeded #{@_suppress} lines"
            
            for line in lines
                lineTxt = line.replace(/[\r\n]/g,'')
                if chunk.added
                    output += "<code class='line-added'>+   #{lineTxt}</code>\n"
                else if chunk.removed
                    output += "<code class='line-removed'>-   #{lineTxt}</code>\n"
                else
                    output += "    #{lineTxt}\n"
                    
        return output


module.exports = HtmlReporter