require! {
  \events
  \async
  \fs
}

c = new events.EventEmitter
try
  c <<< JSON.parse fs.readFileSync "./token.json"
catch e
  c.token = process.env.TOKEN
  c.key = process.env.KEY
  c.secret = process.env.SECRET
  
module.exports = c