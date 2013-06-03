require! {
  \events
  \fs
}

c        = new events.EventEmitter
c.token  = process.env.TOKEN
c.key    = process.env.KEY
c.users  = process.env.USERS
try c <<< JSON.parse fs.readFileSync "./default.json"

module.exports = c