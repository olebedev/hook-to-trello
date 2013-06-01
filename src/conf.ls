require! {
  \events
  \async
  \fs
}

c = new events.EventEmitter
try
  c <<< JSON.parse fs.readFileSync "./default.json"
catch e
  c.token = process.env.TOKEN
  c.key = process.env.KEY
  c.secret = process.env.SECRET

c.people-file = process.env.PEOPLE || "./people.json"
module.exports = c