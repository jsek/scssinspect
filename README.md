![jsinspect](images/scssinspect-logo2shadow.png)

Detect copy-pasted and structurally similar code in your Scss stylesheets.

[![NPM info](https://nodei.co/npm/scssinspect.png?downloads=true)](https://nodei.co/npm/scssinspect.png?downloads=true)

[![dependencies](https://david-dm.org/jsek/scssinspect.png)](https://david-dm.org/jsek/scssinspect) 
[![licence](https://img.shields.io/npm/l/scssinspect.svg)](https://github.com/jsek/scssinspect/blob/master/LICENSE)
[![npm version](http://img.shields.io/npm/v/scssinspect.svg)](https://npmjs.org/package/scssinspect) 
[![releases](https://img.shields.io/github/release/jsek/scssinspect.svg)](https://github.com/jsek/scssinspect/releases) 

* [Overview](#overview)
* [Installation](#installation)
* [Usage](#usage)
* [Known issues](#known-issues)

## Overview

Example console output:

![screenshot](images/screenshot_0.1.4.png)

[Example HTML report](https://github.com/jsek/scssinspect/blob/master/images/html-reporter_0.2.1.png)

## Installation

Global installation (recommended):

```
npm i -g scssinspect
```

## Usage

```
Usage: scssinspect [options] <paths ...>

Duplicate code and structure detection for Scss.
Values matching is enabled by default. Example use:
scssinspect --ignore "merged.scss" ./path/to/src

Options:

  -h, --help                         output usage information
  -V, --version                      output the version number
  -t, --threshold <number>           minimal length of duplicated text (default: 50)
      --syntax                       print syntax trees only
  -c, --config                       path to config file (default: .scssinspectrc)
  -r, --reporter <name>              specify the reporter to use (you can also set custom path to *.js file)
  -s, --skip                         skip files with parsing errors
  -D, --no-diff                      disable 2-way diffs
  -C, --no-color                     disable colors
  --ignore <pattern>                 ignore paths matching a regex
```

If a `.scssinspectrc` file is located in the project directory, its values will
be used in place of the defaults listed above. For example:

``` javascript
{
  "threshold"     : 100,
  "diff"          : "true",
  "reporter"      : "html",
  "skip"          : "false",
  "ignore"        : "bootstrap|legacy|lib" // used as RegExp
}
```

## Known issues
        
 - CLI issues
    - local installation throws exception