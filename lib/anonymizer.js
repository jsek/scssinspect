var Anonymizer, children, dfs;

children = function(node) {
  return node.slice(1);
};

dfs = function(node, callback) {
  var child, i, len, ref, results;
  if (node) {
    if (callback(node) !== false) {
      ref = children(node);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        child = ref[i];
        results.push(dfs(child, callback));
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
      return function(node) {
        return _this._onMatchedByType(node, type, function(n) {
          n[_this._index(1)] = value;
          if (options != null ? options.trim : void 0) {
            return n.splice(_this._index(1) + 1, n.length);
          }
        });
      };
    })(this));
  };

  Anonymizer.prototype._replaceNode = function(tree, type, value, options) {
    return dfs(tree, (function(_this) {
      return function(node) {
        return _this._onMatchedByType(node, type, function(n) {
          return n.splice.apply(n, [0, n.length].concat(value));
        });
      };
    })(this));
  };

  Anonymizer.prototype._onMatchedByType = function(node, type, action) {
    if (node instanceof Array) {
      if ((node != null ? node[this._index(0)] : void 0) === type) {
        action(node);
      }
      return true;
    } else {
      return false;
    }
  };

  Anonymizer.prototype._fakeNode = function() {
    return this._addInfo(['ident', 'x']);
  };

  Anonymizer.prototype.anonymize = function(tree, type, needInfo) {
    var newSelector;
    this.needInfo = !!needInfo;
    switch (type) {
      case 'arguments':
        return this._anonymizeValue(tree, type, this._fakeNode(), {
          trim: true
        });
      case 'base64':
        return this._anonymizeValue(tree, type, 'data:image/png;base64,abc');
      case 'class':
        return this._anonymizeValue(tree, type, this._fakeNode());
      case 'interpolation':
        return this._replaceNode(tree, 'interpolatedVariable', this._fakeNode());
      case 'number':
        return this._anonymizeValue(tree, type, 0);
      case 'selector':
        newSelector = this._addInfo(['simpleselector', this._fakeNode()]);
        return this._anonymizeValue(tree, type, newSelector, {
          trim: true
        });
      case 'string':
        return this._anonymizeValue(tree, type, '"?"');
      case 'url':
        return this._anonymizeValue(tree, 'uri', this._fakeNode());
      case 'value':
        return this._anonymizeValue(tree, type, this._fakeNode(), {
          trim: true
        });
      case 'variable':
        return this._anonymizeValue(tree, type, this._fakeNode());
    }
  };

  return Anonymizer;

})();

module.exports = function() {
  return new Anonymizer();
};
