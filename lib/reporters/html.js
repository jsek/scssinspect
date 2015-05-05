var BaseReporter, HtmlReporter, util,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

util = require('util');

BaseReporter = require('./base');


/**
 * The HTML reporter, which generates markup.
 */

HtmlReporter = (function(superClass) {
  extend(HtmlReporter, superClass);


  /**
   * Open HTML file at the beginning.
   */

  function HtmlReporter(inspector, opts) {
    if (opts == null) {
      opts = {};
    }
    HtmlReporter.__super__.constructor.call(this, inspector, opts);
    this._diff = opts.diff;
    process.stdout.write("<!doctype html>\n<html>\n<head>\n    <style>body{font-family:'Calibri Light',sans-serif;background:#333;color:#eee;padding-top:2em;text-shadow:1px 1px #000}header{font-size:14px;border-bottom:1px solid rgba(255,255,255,.2);margin-bottom:.3em;margin-top:1.3em}h3{font-size:12px;margin:.1em}footer{color:#eee;position:fixed;width:100%;left:0;top:0}.success{background:#4f3;padding:.5em 1em;display:block;box-shadow:0 3px 5px rgba(55,255,55,.5)}.failure{background:#f43;padding:.5em 1em;display:block;box-shadow:0 3px 5px rgba(255,55,55,.5)}.skipped{right:1em;top:.5em;color:#ff0;position:absolute;font-weight:400;font-size:.8em;padding:.3em .2em .1em;border-bottom:1px solid #ff0;text-shadow:none}.warn{color:#ff0;font-size:10px;font-weight:400;font-family:Consolas;padding:.3em}.warn-file{color:#0ff}.diff{padding:1em;font-size:10px;background:#222;color:#eee;border-radius:3px}.diff-files{color:#bbb}.line-added{color:#54cc54}.line-removed{color:#d45e67}</style>\n    <title>" + (new Date()) + "</title>\n</head>\n<body>");
    this._registerSummary();
  }


  /**
   * Returns HTML report content. The <header> tag contains all statistics.
   */

  HtmlReporter.prototype._getOutput = function(match) {
    var currentDiffIndex, diff, files, i, j, len, len1, node, nodes, output, ref, source;
    nodes = match.nodes;
    output = "<header>Match - " + nodes.length + " instances</header>";
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      source = this._getFormattedLocation(node);
      output += "<h3>" + (source.replace(/\n/g, '<br>')) + "</h3>";
    }
    if (this._diff !== 'none') {
      currentDiffIndex = 0;
      ref = match.diffs;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        diff = ref[j];
        output += "<pre class='diff'>";
        currentDiffIndex++;
        files = "- " + (this._getFormattedLocation(nodes[0])) + "\n+ " + (this._getFormattedLocation(nodes[currentDiffIndex])) + "\n";
        output += ("<code class='diff-files'>" + files + "</code>") + this._getFormattedDiff(diff);
        output += "</pre>";
      }
    }
    return output;
  };


  /**
   * Returns formatted warning message.
   */

  HtmlReporter.prototype._getWarning = function(warn) {
    return "<div class='warn'><b>WARNING</b>: " + warn.message + " <span class='warn-file'>" + warn.path + "</span><br> &gt; " + warn.error.message + "</div>";
  };


  /**
   * @override
   * Returns formatted summary message in <footer> and closes HTML file.
   */

  HtmlReporter.prototype._registerSummary = function() {
    return this._inspector.on('end', (function(_this) {
      return function() {
        var checked, found, numFiles, skipped, total;
        found = '';
        total = '';
        numFiles = _this._inspector.numFiles;
        checked = numFiles + " " + (_this._pluralize(numFiles, 'file'));
        skipped = _this._skipped ? "<span class='skipped'>" + _this._skipped + " " + (_this._pluralize(_this._skipped, 'file')) + " skipped</span>" : '';
        if (!_this._found) {
          found = "<span class='success'>No matches found across " + checked + "</span>";
        } else {
          total = "Total size: " + _this._totalSize + " " + (_this._pluralize(_this._totalSize, _this._thresholdTypeName));
          found = "<span class='failure'>" + _this._found + " " + (_this._pluralizeE(_this._found, 'match')) + " found across " + checked + " (" + total + ")</span>";
        }
        process.stdout.write('<footer>' + found + skipped + '</footer>');
        return process.stdout.write("</body>\n</html>");
      };
    })(this));
  };


  /**
   * @override
   * Returns formatted diff to be placed in <pre> tag.
   */

  HtmlReporter.prototype._getFormattedDiff = function(diff) {
    var chunk, diffLength, i, j, len, len1, line, lineTxt, lines, output;
    output = '\n';
    diffLength = 0;
    for (i = 0, len = diff.length; i < len; i++) {
      chunk = diff[i];
      lines = chunk.value.split('\n');
      if (chunk.value.slice(-1) === '\n') {
        lines = lines.slice(0, -1);
      }
      diffLength += lines.length;
      if (this._suppress && diffLength > this._suppress) {
        return "Diff suppressed as it exceeded " + this._suppress + " lines";
      }
      for (j = 0, len1 = lines.length; j < len1; j++) {
        line = lines[j];
        lineTxt = line.replace(/[\r\n]/g, '');
        if (chunk.added) {
          output += "<code class='line-added'>+   " + lineTxt + "</code>\n";
        } else if (chunk.removed) {
          output += "<code class='line-removed'>-   " + lineTxt + "</code>\n";
        } else {
          output += "    " + lineTxt + "\n";
        }
      }
    }
    return output;
  };

  return HtmlReporter;

})(BaseReporter);

module.exports = HtmlReporter;
