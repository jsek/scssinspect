var Helper, chalk, enabled, fixtures, parseCache, write;

chalk = require('chalk');

fixtures = require('./fixtures');

enabled = chalk.enabled;

write = process.stdout.write;

parseCache = {};

Helper = (function() {
  function Helper() {
    this.output = '';
  }

  Helper.prototype.captureOutput = function() {
    chalk.enabled = false;
    this.output = '';
    return process.stdout.write = (function(_this) {
      return function(string) {
        if (string) {
          return _this.output += string;
        }
      };
    })(this);
  };

  Helper.prototype.getOutput = function() {
    return this.output;
  };

  Helper.prototype.restoreOutput = function() {
    chalk.enabled = enabled;
    return process.stdout.write = write;
  };

  Helper.prototype.safeTestOutput = function(Inspector, Reporter, filename, options, testFn) {
    var inspector, reporter;
    if (typeof options === 'function') {
      testFn = options;
      options = {};
    }
    try {
      inspector = new Inspector([fixtures[filename]], options);
      reporter = new Reporter(inspector, options);
      if (options.ignoreSummary) {
        inspector.removeAllListeners('end');
      }
      return inspector.run();
    } catch (_error) {
      throw new Error('Exception while executing spec');
    } finally {
      this.restoreOutput();
      testFn(this.getOutput());
    }
  };

  return Helper;

})();

module.exports = new Helper();
