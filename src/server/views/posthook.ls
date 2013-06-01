require! {
  \fs
  \colors
  \request
  \async
  \../../conf
  _:\prelude-ls
  qs: \querystring
}

default-commit = {}

class BitTrelloClient
  (@board, @payload, @token, @key) ->
  
  match-list: (name) ->
    for list in @board.lists
      return list if list.name.match new RegExp name, "i"
    null

  URL:"https://api.trello.com/1/"

  sign: (url) ->
    url += if url.split("?").length >= 2
           then "&token=#{@token}&key=#{@key}"
           else "?token=#{@token}&key=#{@key}"
    url

  get-card: (id, next) -->
    err, resp, body <~ request @sign "#{@URL}boards/#{@board.id}/cards/#{id}"
    try
      next err, JSON.parse body
    catch e
      next err || e, body

  add-comment: (id, comment="", next=(->)) -->
    err, resp, body <~ request do
      url: @sign "#{@URL}cards/#{id}/actions/comments"
      method: "POST"
      json: 
        text: comment
    try
      next err, JSON.parse body
    catch e
      next err || e, body

  update-card: (id, params, next) -->
    err, resp, body <~ request do
      url: @sign "#{@URL}cards/#{id}"
      method: "PUT"
      json: params

    next err

  action-move: (commit, next) -->
    err, card <~ @get-card commit.action.move
    unless commit.action.noco? 
      err, comment-result <~ @add-comment card.id, "#{commit.author}: #{commit.message}\n\n#{@payload.canon_url + @payload.repository.absolute_url}commits/#{commit.raw_node}" # commit.message
    
    list = @match-list commit.action.to
    if list?
      err, updt <~ @update-card card.id, {idList: list.id}
      next!
    else
      console.log "list not found", commit.action.to
      process.next-tick next

  handle-commit: (commit={}, next=(->)) -->
    commit = {} <<< default-commit <<< commit
    commit.action = qs.parse commit.message.split("?", 2)[1].trim! 
    commit.message = commit.message.split("?", 2)[0].trim! # clean message
    err <~ @set-action-author commit
    return next err if err?
    for k,v of commit.action
      switch k
      | "move" => @action-move commit, next

  read-http-file: (url, next) ->

    err, resp, body <- request url
    console.log "fetch file from http".green, url.grey
    next err, body

  set-action-author: (commit, next) ->
    return process.next-tick(next) if @token? and @key?
    
    fn = if conf.people-file.match(//http//)? then @read-http-file else fs.read-file
    err, people <~ fn conf.people-file
    
    if err?
      # default token & key
      @token = conf.token
      @key   = conf.key
      return next err if err?

    try people = JSON.parse people
    unless typeof! people is "Object"
      return next new Error("The file type(#{typeof! people}) is not as expected.")

    for k,v of people
      for alias in v.aliases || [k]
        if alias is @payload.user
          @token = v.token
          @key = v.key
          return next!

    # default token & key
    @token = conf.token
    @key   = conf.key

    next!

class GitHubTrelloClient extends BitTrelloClient


module.exports = (req,res) ->
  req.params.id = req.params.provider unless req.params.id?
  err, resp, body <~ request "https://api.trello.com/1/board/#{req.params.id}?token=#{conf.token}&key=#{conf.key}&lists=all"
  try body = JSON.parse body
  return res.send body if //invalid//.test body

  /**
   * LET'S GO
   */
  try
    msg = JSON.parse req.body.payload || '{}'
  catch
    msg = req.body.payload

  console.log "[__POST__]".green, "by #{msg.user}".grey

  Client = switch req.params.provider
  | "b"        => BitTrelloClient
  | "g"        => GitHubTrelloClient
  | otherwise  => BitTrelloClient

  client = new Client body, msg

  [client.handle-commit i, null for i in msg.commits || []] # callback TODO: implement async calls

  res.json do
    req-body: body
    body: req.body
