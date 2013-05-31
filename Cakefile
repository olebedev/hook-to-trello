fs = require 'fs'
path = require 'path'
eco = require 'eco'
{indent} = require 'eco/lib/util'

option '-f', '--file [FILE]'

task 'eco', 'Build template file', (options)->
  output = []
  source = fs.readFileSync options.file, "utf8"
  modulename = options.file.split(path.sep).pop().replace '.eco', ''
  template = indent(eco.precompile(source), 2)
  output.push "({define:typeof define!='undefined'?define:function(deps, factory){module.exports = factory();}}).
define([], function(){\n  var exports = "
  output.push template.slice(2) + ";\n"
  output.push "  return exports;\n});"
  console.log output.join("")