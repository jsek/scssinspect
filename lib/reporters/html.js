var BaseReporter, HtmlReporter, util,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

util = require('util');

BaseReporter = require('./base');


/**
 * The HTML reporter, which generates markup. Reqiures scssinspect.css.
 */

HtmlReporter = (function(superClass) {
  extend(HtmlReporter, superClass);

  function HtmlReporter(inspector, opts) {
    if (opts == null) {
      opts = {};
    }
    HtmlReporter.__super__.constructor.call(this, inspector, opts);
    this._diff = opts.diff;
    process.stdout.write("<!doctype html>\n<html>\n<head>\n    <link rel='stylesheet' href='scssinspect.css' />\n    <title>" + (new Date()) + "</title>\n</head>\n<body>");
    this._registerSummary();
  }

  HtmlReporter.prototype._getOutput = function(match) {
    var currentDiffIndex, diff, files, i, j, len, len1, node, nodes, output, ref, source;
    nodes = match.nodes;
    output = "<header>Match - " + nodes.length + " instances</header>";
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      source = this._getFormattedLocation(node);
      output += "<h3>" + (source.replace(/\n/g, '<br>')) + "</h3>";
    }
    if (this._diff) {
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

  HtmlReporter.prototype._getWarning = function(warn) {
    return "<div class='warn'><b>WARNING</b>: " + warn.message + " <span class='warn-file'>" + warn.path + "</span><br> &gt; " + warn.error.message + "</div>";
  };

  HtmlReporter.prototype._registerSummary = function() {
    return this._inspector.on('end', (function(_this) {
      return function() {
        var checked, found, numFiles, skipped;
        found = '';
        numFiles = _this._inspector.numFiles;
        checked = numFiles + " " + (_this._pluralize(numFiles, 'file'));
        skipped = _this._skipped ? "<span class='skipped'>" + _this._skipped + " " + (_this._pluralize(_this._skipped, 'file')) + " skipped</span>" : '';
        if (!_this._found) {
          found = "<span class='success'>No matches found across " + checked + "</span>";
        } else {
          found = "<span class='failure'>" + _this._found + " " + (_this._pluralizeE(_this._found, 'match')) + " found across " + checked + "</span>";
        }
        process.stdout.write('<footer>' + found + skipped + '</footer>');
        return process.stdout.write("</body>\n</html>");
      };
    })(this));
  };

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
