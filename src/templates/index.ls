path = require "path"
fs   = require "fs"

for i in fs.readdirSync __dirname when !i.match(//index//)?
  name = i.split(".")[to -2].join "."
  exports[name] = require(path.resolve __dirname, name)