var BaseReporter, DefaultReporter, chalk, util,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

util = require('util');

chalk = require('chalk');

BaseReporter = require('./base');


/**
 * The default reporter, which displays both file and line information for
 * each given match. If enabled via opts.diff, corresponding diffs are also
 * printed.
 */

DefaultReporter = (function(superClass) {
  extend(DefaultReporter, superClass);


  /**
   * @constructor
  #
   * @param {Inspector} inspector The instance on which to register its listeners
   * @param {object}    opts      Options to set for the reporter
   */

  function DefaultReporter(inspector, opts) {
    if (opts == null) {
      opts = {};
    }
    DefaultReporter.__super__.constructor.call(this, inspector, opts);
    this._diff = opts.diff;
    this._registerSummary();
  }


  /**
   * Returns the string output to print for the given reporter. The string
   * contains the number of instances associated with the match and the files
   * and lines involved. If diffs are enabled, 2-way diffs are formatted and
   * included.
  #
   * @private
  #
   * @param   {Match}  match The inspector match to output
   * @returns {string} The formatted output
   */

  DefaultReporter.prototype._getOutput = function(match) {
    var currentDiffIndex, diff, files, i, j, len, len1, node, nodes, output, ref, source;
    nodes = match.nodes;
    output = '\n' + chalk.bold("Match - " + nodes.length + " instances\n");
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      source = this._getFormattedLocation(node) + '\n';
      output += this._diff ? chalk.bold(source) : source;
    }
    if (this._diff) {
      currentDiffIndex = 0;
      ref = match.diffs;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        diff = ref[j];
        currentDiffIndex++;
        files = "- " + (this._getFormattedLocation(nodes[0])) + "\n+ " + (this._getFormattedLocation(nodes[currentDiffIndex])) + "\n";
        output += '\n' + chalk.grey(files) + this._getFormattedDiff(diff);
      }
    }
    return output;
  };


  /**
   * Returns the formatted warning message.
  #
   * @private
  #
   * @param   {Match}  match The inspector match to output
   * @returns {string} The formatted output
   */

  DefaultReporter.prototype._getWarning = function(warn) {
    return chalk.yellow((chalk.bold('WARNING')) + ": " + warn.message + " " + (chalk.cyan(warn.path)) + "\n > " + warn.error.message + "\n");
  };

  return DefaultReporter;

})(BaseReporter);

module.exports = DefaultReporter;
