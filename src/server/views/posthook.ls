require! {
  \colors
  \request
  \../../conf
  qs: \querystring
  _:\prelude-ls
}

default-commit = {}

class TrelloClient
  (@board, @payload, @token=conf.token, @key=conf.key) ->
  
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
    err, card <~ @get-card commit.action.card
    err, comment-result <~ @add-comment card.id, "#{commit.author}: #{commit.message}\n\n#{@payload.canon_url + @payload.repository.absolute_url}commits/#{commit.raw_node}" # commit.message
    list = @match-list commit.action.list
    if list?
      err, updt <~ @update-card card.id, {idList: list.id}
      next!
    else
      process.next-tick next

  handle-commit: (commit={}, next=(->)) -->
    commit = {} <<< default-commit <<< commit
    commit.action = qs.parse commit.message.split("?", 2)[1].trim! 
    commit.message = commit.message.split("?", 2)[0].trim! # clean message

    switch commit.action.act
    | "move" => @action-move commit, next


module.exports = (req,res) ->
  err, resp, body <~ request "https://api.trello.com/1/board/#{req.params.id}?token=#{conf.token}&key=#{conf.key}&lists=all"
  try body = JSON.parse body
  return res.send body if //invalid//.test body


  /**
   * LET'S GO
   */

  msg = req.body.payload
  acc = []
  for i in msg.commits
    obj = qs.parse i.message.split("?", 2)[1].trim!
    obj.message = i.message.split("?", 2)[0].trim!
    acc.push obj

  client = new TrelloClient body, req.body.payload

  [client.handle-commit i, null for i in msg.commits]# callback TODO: implement async calls

  res.json do
    acc: acc
    req-body: body
    body: req.body
