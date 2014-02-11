require! {
  \events
  \fs
}

c           = new events.EventEmitter
c.token     = process.env.TOKEN
c.key       = process.env.KEY
c.users     = process.env.USERS || "./users.json"
c.separator = new RegExp(process.env.SEPARATOR || "\\s{2,}")
try c <<< require "./default.json"

module.exports = c