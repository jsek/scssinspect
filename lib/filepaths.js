var checkIgnorePatterns, checkSuffix, file, findLocalIgnorePatterns, fs, getFilePath, mergeIgnorePatterns, sep;

fs = require('fs');

sep = require('path').sep;

file = require('file');

getFilePath = function(file, dirPath) {
  if (/(^[A-Za-z]:)/g.test(dirPath)) {
    return dirPath + '\\' + file;
  } else {
    if (dirPath.slice(-1) !== sep) {
      dirPath += sep;
    }
    if (dirPath.indexOf(sep) !== 0 && dirPath.indexOf('.') !== 0) {
      dirPath = './' + dirPath;
    }
    return dirPath + file;
  }
};


/*
 * Verify if the file has specified suffix (extension)
 */

checkSuffix = function(file, suffix) {
  return !suffix || file.slice(-suffix.length) === suffix;
};


/*
 * Recognize if the file is NOT covered by ignore patterns
 */

checkIgnorePatterns = function(filePath, ignorePatterns) {
  var j, len, regexp;
  for (j = 0, len = ignorePatterns.length; j < len; j++) {
    regexp = ignorePatterns[j];
    if (regexp.test(filePath)) {
      return false;
    }
  }
  return true;
};


/*
 * Prepare merged array of ignore patterns from global patterns and
 * localPatterns from the current and parent directories
 */

mergeIgnorePatterns = function(globalPatterns, localPatterns, dirPath) {
  var dir, result;
  result = globalPatterns;
  for (dir in localPatterns) {
    if (dirPath.indexOf(dir) === 0) {
      result = result.concat(localPatterns[dir]);
    }
  }
  return result;
};


/*
 * Find local ignore patterns stored in the given directory
 */

findLocalIgnorePatterns = function(localIgnorePatterns, dirPath, files, specialFileName) {
  if (files.filter(function(f) {
    return f === specialFileName;
  }).length > 0) {
    return localIgnorePatterns[dirPath] = fs.readFileSync(dirPath + '\\' + specialFileName, {
      encoding: 'utf8'
    }).replace('**', '.*').replace('/*.', '/.*.').replace('/', '\\').split('\n').map(function(i) {
      return i.trim();
    }).filter(function(i) {
      return i.length;
    }).map(function(i) {
      return new RegExp(i);
    });
  }
};


/*
 * Return list of paths to the files in scope of further analysis
 */

exports.getSync = function(paths, opts) {
  var globalIgnorePatterns, j, len, localIgnorePatterns, path, results;
  paths = paths || [];
  opts = opts || {};
  results = [];
  localIgnorePatterns = {};
  globalIgnorePatterns = opts.ignore.map(function(i) {
    return new RegExp(i);
  });
  for (j = 0, len = paths.length; j < len; j++) {
    path = paths[j];
    if (!fs.existsSync(path)) {
      throw new Error('No such file or directory: ' + path);
    } else if (fs.statSync(path).isFile()) {
      results.push(path);
    } else {
      file.walkSync(path, function(dirPath, dirs, files) {
        var f, filePath, k, len1, patterns, results1;
        findLocalIgnorePatterns(localIgnorePatterns, dirPath, files, opts.localIgnoreFile);
        patterns = mergeIgnorePatterns(globalIgnorePatterns, localIgnorePatterns, dirPath);
        results1 = [];
        for (k = 0, len1 = files.length; k < len1; k++) {
          f = files[k];
          filePath = getFilePath(f, dirPath);
          if (checkSuffix(f, opts.suffix) && checkIgnorePatterns(filePath, patterns)) {
            results1.push(results.push(filePath));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      });
    }
  }
  return results;
};
