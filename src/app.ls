require! {
  \express
  \./server/urls
  \./conf
  \colors
}

app = express!
app.use express.bodyParser!
app.use express.favicon!

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

