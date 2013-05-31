require! {
  \express
  \./server/urls
  \./conf
  \colors
}

app = express!
app.use express.favicon!
app.use express.bodyParser!
app.use '/static', express.static __dirname + '/static'
app.use "/static/libs", express.static __dirname + '/vendors'
app.use "/static/tmpl", express.static __dirname + '/templates'

app.configure "development", ->
  app.use express.errorHandler do
    dumpExceptions: true
    showStack: true
  app.use express.logger format: ':method :url'
  
app.configure "production", ->
  app.use express.logger format: ':method :url'

urls.bind app
PORT = process.env.PORT or 5000
app.listen PORT, -> 
  console.info "Listening #{PORT} port...".grey

