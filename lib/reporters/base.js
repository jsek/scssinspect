var BaseReporter, chalk, path, util;

util = require('util');

path = require('path');

chalk = require('chalk');


/**
 * A base reporter from which all others inherit. Registers a listener on the
 * passed inspector instance for tracking the number of matches found.
 */

BaseReporter = (function() {
  function BaseReporter(_inspector, opts) {
    this._inspector = _inspector;
    if (opts == null) {
      opts = {};
    }
    this._found = 0;
    this._skipped = 0;
    this._totalSize = 0;
    this._thresholdTypeName = this._getThresholdTypeName(opts.thresholdType || 'char');
    this._registerListener();
  }


  /**
   * Helpers
   */

  BaseReporter.prototype._pluralize = function(count, text) {
    if (count !== 1) {
      if (text.slice(-1) === 'y') {
        return text.slice(0, -1) + 'ies';
      } else {
        return text + 's';
      }
    } else {
      return text;
    }
  };

  BaseReporter.prototype._pluralizeE = function(count, text) {
    if (count !== 1) {
      return text + 'es';
    } else {
      return text;
    }
  };

  BaseReporter.prototype._getThresholdTypeName = function(type) {
    if (type === 'char') {
      return 'character';
    } else {
      return type;
    }
  };


  /**
   * Registers a listener to the "match" event exposed by the Inspector instance.
   * Increments _found for each match emitted, and invokes the object's
   * _getOutput method, writing it to stdout.
   */

  BaseReporter.prototype._registerListener = function() {
    this._inspector.on('match', (function(_this) {
      return function(match) {
        _this._found++;
        _this._totalSize += match.duplicationSize;
        return process.stdout.write(_this._getOutput(match));
      };
    })(this));
    return this._inspector.on('warning', (function(_this) {
      return function(warn) {
        _this._skipped++;
        return process.stdout.write(_this._getWarning(warn));
      };
    })(this));
  };


  /**
   * Registers a listener that prints a final summary outlining the number of
   * matches detected, as well as the number of files analyzed.
   */

  BaseReporter.prototype._registerSummary = function() {
    return this._inspector.on('end', (function(_this) {
      return function() {
        var checked, found, numFiles, skipped, total;
        found = '';
        total = '';
        numFiles = _this._inspector.numFiles;
        checked = numFiles + " " + (_this._pluralize(numFiles, 'file'));
        skipped = _this._skipped ? " (" + _this._skipped + " " + (_this._pluralize(_this._skipped, 'file')) + " skipped)" : '';
        if (!_this._found) {
          found = chalk.black.bgGreen(" No matches found across " + checked + " ");
        } else {
          found = chalk.white.bgRed(" " + _this._found + " " + (_this._pluralizeE(_this._found, 'match')) + " found across " + checked + " ");
          total = chalk.white.bgRed("\n Total size: " + _this._totalSize + " " + (_this._pluralize(_this._totalSize, _this._thresholdTypeName)) + " ");
        }
        return process.stdout.write('\n' + found + skipped + total + '\n');
      };
    })(this));
  };


  /**
   * Accepts a diff object and returns a corresponding formatted diff string.
   * The object contains three keys: value, a string with possible newlines,
   * added, a boolean indicating if it were an addition, and removed, for if it
   * were removed from the src. The formatted diff is padded and uses "+" and "-"
   * for indicating the addition and removal of lines.
   */

  BaseReporter.prototype._getFormattedDiff = function(diff) {
    var chunk, diffLength, i, j, len, len1, line, lines, output;
    output = '';
    diffLength = 0;
    for (i = 0, len = diff.length; i < len; i++) {
      chunk = diff[i];
      lines = chunk.value.split('\n');
      if (chunk.value.slice(-1) === '\n') {
        lines = lines.slice(0, -1);
      }
      diffLength += lines.length;
      for (j = 0, len1 = lines.length; j < len1; j++) {
        line = lines[j];
        if (chunk.added) {
          output += chalk.green("+   " + line + "\n");
        } else if (chunk.removed) {
          output += chalk.red("-   " + line + "\n");
        } else {
          output += "    " + line + "\n";
        }
      }
    }
    return output;
  };


  /**
   * Returns a string containing the path to the file in which the node is
   * located, as well as the lines on which the node exists.
   */

  BaseReporter.prototype._getFormattedLocation = function(node) {
    var filePath;
    filePath = node.loc.source;
    if (filePath.charAt(0) === '/') {
      filePath = path.relative(process.cwd(), filePath);
    }
    return filePath + (":" + node.loc.start + "," + node.loc.end);
  };

  return BaseReporter;

})();

module.exports = BaseReporter;
