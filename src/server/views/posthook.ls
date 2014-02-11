require! {
  \fs
  \colors
  \request
  \async
  \../../conf
  _:\prelude-ls
  qs: \querystring
  \./help
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

  make-message: (commit) ->
    "#{commit.author}: #{commit.message}\n\n#{@payload.canon_url + @payload.repository.absolute_url}commits/#{commit.raw_node}"

  action-move: (commit, next) -->
    err, card <~ @get-card commit.options.move
    unless commit.options.noco? 
      err, comment-result <~ @add-comment card.id, @make-message(commit)
    
    list = @match-list commit.options.to
    if list?
      err, updt <~ @update-card card.id, {idList: list.id}
      next!
    else
      console.log "list not found", commit.options.to
      process.next-tick next

  handle-commit: (commit={}, next) ~~>
    commit = {} <<< default-commit <<< commit <<< help.parse commit.message
    err <~ @set-action-author commit
    return next err if err?

    console.log "handle-commit", commit
    for k,v of commit.options
      switch k
      | "move" => return @action-move commit, next

  set-action-author: (commit, next) ->
    return process.next-tick(next) if @token? and @key?
    
    err, people <~ help.read-file conf.users
    
    if err? or !conf.users?
      # default token & key
      @token = conf.token
      @key   = conf.key
      return next err if err?

    try people = JSON.parse people
    unless typeof! people is "Object"
      return next new Error("The file type(#{typeof! people}) is not as expected.")

    for k,v of people
      for alias in v.aliases || [k]
        if alias is @get-commit-user commit
          @token = v.token
          @key = v.key
          return next!

    # default token & key
    @token = conf.token
    @key   = conf.key

    next!

  get-commit-user: (commit) ->
    @payload.user

class GitHubTrelloClient extends BitTrelloClient

  get-commit-user: (commit) ->
    commit.committer?.name 

  make-message: (commit) ->
    "#{commit.committer.name}: #{commit.message}\n\n#{commit.url}"

module.exports = (req,res) ->
  req.params.id = req.params.provider unless req.params.id?
  url = "https://api.trello.com/1/board/#{req.params.id}?token=#{conf.token}&key=#{conf.key}&lists=all"
  err, resp, body <~ request url
  try body = JSON.parse body
  if //invalid//.test body
    return res.send body 

  /**
   * LET'S GO
   */
  try
    msg = JSON.parse req.body.payload || '{}'
  catch
    msg = req.body.payload

  console.log "[__POST__]".green, "by #{msg.user || msg.pusher?.name}".grey

  Client = switch req.params.provider
  | "b"        => BitTrelloClient
  | "g"        => GitHubTrelloClient
  | otherwise  => BitTrelloClient

  client = new Client body, msg
  
  # handle in background
  async.map msg.commits, client.handle-commit, (err)-> console.log err.toString!.red if err?

  res.json do
    req-body: body
    body: req.body
