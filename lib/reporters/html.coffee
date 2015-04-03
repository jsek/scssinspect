util         = require('util')
BaseReporter = require('./base')

###*
# The HTML reporter, which generates markup.
###
class HtmlReporter extends BaseReporter

    constructor: (inspector, opts = {}) ->
        super inspector, opts
        @_diff = opts.diff
        process.stdout.write """
            <!doctype html>
            <html>
            <head>
                <style>body{font-family:'Calibri Light',sans-serif;background:#333;color:#eee;padding-top:2em;text-shadow:1px 1px #000}header{font-size:14px;border-bottom:1px solid rgba(255,255,255,.2);margin-bottom:.3em;margin-top:1.3em}h3{font-size:12px;margin:.1em}footer{color:#eee;position:fixed;width:100%;left:0;top:0}.success{background:#4f3;padding:.5em 1em;display:block;box-shadow:0 3px 5px rgba(55,255,55,.5)}.failure{background:#f43;padding:.5em 1em;display:block;box-shadow:0 3px 5px rgba(255,55,55,.5)}.skipped{right:1em;top:.5em;color:#ff0;position:absolute;font-weight:400;font-size:.8em;padding:.3em .2em .1em;border-bottom:1px solid #ff0;text-shadow:none}.warn{color:#ff0;font-size:10px;font-weight:400;font-family:Consolas;padding:.3em}.warn-file{color:#0ff}.diff{padding:1em;font-size:10px;background:#222;color:#eee;border-radius:3px}.diff-files{color:#bbb}.line-added{color:#54cc54}.line-removed{color:#d45e67}</style>
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


        unless @_diff is 'none'
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
        return "<div class='warn'><b>WARNING</b>: #{warn.message} <span class='warn-file'>#{warn.path}</span><br> &gt; #{warn.error.message}</div>"

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