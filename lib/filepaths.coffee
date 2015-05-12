fs   = require('fs')
sep  = require('path').sep
file = require('file')


getFilePath = (file, dirPath) ->
    if /(^[A-Za-z]:)/g.test(dirPath)
        return dirPath + '\\' + file
    else
        if dirPath.slice(-1) != sep
            dirPath += sep
        if dirPath.indexOf(sep) != 0 and dirPath.indexOf('.') != 0
            dirPath = './' + dirPath
        return dirPath + file

###
# Verify if the file has specified suffix (extension)
###
checkSuffix = (file, suffix) ->
    return !suffix or file[(-suffix.length)..] is suffix

###
# Recognize if the file is NOT covered by ignore patterns
###
checkIgnorePatterns = (filePath, ignorePatterns) ->
    for regexp in ignorePatterns
        if regexp.test(filePath)
            return false
    return true

###
# Prepare merged array of ignore patterns from global patterns and
# localPatterns from the current and parent directories
###
mergeIgnorePatterns = (globalPatterns, localPatterns, dirPath) ->
    result = globalPatterns    
    for dir of localPatterns
        if dirPath.indexOf(dir) is 0
            result = result.concat localPatterns[dir]
    return result

###
# Find local ignore patterns stored in the given directory
###
findLocalIgnorePatterns = (localIgnorePatterns, dirPath, files, specialFileName) ->
    if files.filter((f) -> f is specialFileName).length > 0
        localIgnorePatterns[dirPath] = fs
            .readFileSync(dirPath + '\\' + specialFileName, encoding: 'utf8')
            .replace('**', '.*')
            .replace('/*.', '/.*.')
            .replace('/', '\\')
            .split('\n')
            .map (i) -> i.trim()
            .filter (i) -> i.length
            .map (i) -> new RegExp(i)

###
# Return list of paths to the files in scope of further analysis
###
exports.getSync = (paths, opts) ->
    paths   = paths or []
    opts    = opts or {}
    results = []
    
    localIgnorePatterns  = {}
    globalIgnorePatterns = opts.ignore.map (i) -> new RegExp(i)
    
    for path in paths
        if !fs.existsSync(path)
            throw new Error('No such file or directory: ' + path)
        
        else if fs.statSync(path).isFile()
            results.push(path)
        
        else 
            file.walkSync path, (dirPath, dirs, files) ->
                findLocalIgnorePatterns(localIgnorePatterns, dirPath, files, opts.localIgnoreFile)
                patterns = mergeIgnorePatterns(globalIgnorePatterns, localIgnorePatterns, dirPath)

                for f in files
                    filePath = getFilePath(f, dirPath)
                    
                    if checkSuffix(f, opts.suffix) and checkIgnorePatterns(filePath, patterns)
                        results.push filePath

    return results