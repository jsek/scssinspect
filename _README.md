![jsinspect](scssinspect-logo2shadow.png)

Detect copy-pasted and structurally similar code in your Scss stylesheets.

[![Build Status](https://travis-ci.org/jsek/scssinspect.svg?branch=master)](https://travis-ci.org/jsek/scssinspect)

* [Overview](#overview)
* [Installation](#installation)
* [Usage](#usage)
* [Integration](#integration)
* [Reporters](#reporters) // TODO
* [Performance](#performance) // TODO

## Overview

One example means more than thousand words:

![screenshot](http://danielstjules.com/github/jsinspect-screenshot.png)

## Installation

It can be installed via `npm` using:

``` bash
npm install -g scssinspect
```

## Usage

```
Usage: scssinspect [options] <paths ...>

Duplicate code and structure detection for Scss.
Values matching is enabled by default. Example use:
scssinspect -t 30 -i --ignore "merged.scss" ./path/to/src

Options:

  -h, --help                         output usage information
  -V, --version                      output the version number
  -t, --threshold <number>           number of nodes (default: 15)
  -i, --ignore-values                don't match exact numeric/color values
  -c, --config                       path to config file (default: .scssinspectrc)
  -r, --reporter [default|json]      specify the reporter to use (you can apply your own, just use path to *.js file)
  -s, --suppress <number>            length to suppress diffs (default: 100, off: 0)
  -D, --no-diff                      disable 2-way diffs
  -C, --no-color                     disable colors
  --ignore <pattern>                 ignore paths matching a regex
```

If a `.scssinspectrc` file is located in the project directory, its values will
be used in place of the defaults listed above. For example:

``` javascript
{
  "threshold"     : 30,
  "ignore-values" : true,
  "ignore"        : "bootstrap|legacy|lib", // used as RegExp
  "reporter"      : "json",
  "suppress"      : 100
}
```

## Integration

Example for Travis CI. Expected Entries in your `.travis.yml`:

``` yaml
before_script:
  - "npm install -g scssinspect"

script:
  - "scssinspect -t 30 ./path/to/src"
```