var Anonymizer, children, dfs;

children = function(node) {
  return node.slice(1);
};

dfs = function(node, callback) {
  var c, i, len, ref, results;
  if (node) {
    if (callback(node) !== false) {
      ref = children(node);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        c = ref[i];
        results.push(dfs(c, callback));
      }
      return results;
    }
  }
};

Anonymizer = (function() {
  function Anonymizer() {}

  Anonymizer.prototype._index = function(x) {
    if (this.needInfo) {
      return x + 1;
    } else {
      return x;
    }
  };

  Anonymizer.prototype._addInfo = function(x) {
    if (this.needInfo) {
      x.unshift({});
    }
    return x;
  };

  Anonymizer.prototype._anonymizeValue = function(tree, type, value, options) {
    return dfs(tree, (function(_this) {
      return function(n) {
        if (n instanceof Array) {
          if ((n != null ? n[_this._index(0)] : void 0) === type) {
            n[_this._index(1)] = value;
            if (options != null ? options.trim : void 0) {
              n.splice(_this._index(1) + 1, n.length);
            }
          }
          return true;
        } else {
          return false;
        }
      };
    })(this));
  };

  Anonymizer.prototype.anonymize = function(tree, type, needInfo) {
    var ident, newSelector;
    this.needInfo = !!needInfo;
    switch (type) {
      case 'number':
        return this._anonymizeValue(tree, type, 0);
      case 'string':
        return this._anonymizeValue(tree, type, '"?"');
      case 'selector':
        ident = this._addInfo(['ident', 'x']);
        newSelector = this._addInfo(['simpleselector', ident]);
        return this._anonymizeValue(tree, 'selector', newSelector, {
          trim: true
        });
    }
  };

  return Anonymizer;

})();

module.exports = function() {
  return new Anonymizer();
};
