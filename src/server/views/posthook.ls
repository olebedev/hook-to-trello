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

class BitBucketTrelloClient

  (@board, @payload, @token, @key) ->

  URL:"https://api.trello.com/1/"

  sign: (url) ->
    url += if url.split("?").length >= 2
           then "&token=#{@token}&key=#{@key}"
           else "?token=#{@token}&key=#{@key}"
    url

  get-card: (id, next) -->
    err, resp, body <~ request @sign "#{@URL}boards/#{@board.id}/cards/#{id}"
    try body = JSON.parse body
    next err, body

  add-comment: (id, comment="", next=(->)) -->
    err, resp, body <~ request do
      url: @sign "#{@URL}cards/#{id}/actions/comments"
      method: "POST"
      json:
        text: comment

    try body = JSON.parse body
    next err, body

  update-card: (id, params, next) -->
    err, resp, body <~ request do
      url: @sign "#{@URL}cards/#{id}"
      method: "PUT"
      json: params

    next err, body

  make-message: (commit) ->
    "#{commit.author}: #{commit.message}\n\n#{@payload.canon_url + @payload.repository.absolute_url}commits/#{commit.raw_node}"

  handle-commit: (commit={}, next) ->
    commit = {} <<< default-commit <<< commit <<< help.parse @board.lists, commit.message
    err <~ @set-action-author commit
    return next err if err?
    return next! if !commit.card?

    err, card <~ @get-card commit.card
    return console.log ("" + err).red if err? && !(err == 1)

    err <~ async.series [
      (cbk) ~>
        return cbk 1 if !commit.card? # card id not found => exit 1
        # add message
        err <~ @add-comment card.id, @make-message(commit)
        cbk err

      (cbk) ~>
        return cbk! if !commit.list?
        # move
        err <~ @update-card card.id, {idList: commit.list}
        cbk err
    ]
    return console.log ("" + err).red if err? && !(err == 1)

  set-action-author: (commit, next) ->
    # cache for current http POST request
    err <~ (cbk) ~>
      return cbk null, @_people if @_people?
      err, people <~ help.read-file conf.users
      @_people = people
      unless typeof! people is "Object"
        return next new Error("Could not read users object from users configuration file. Expected Object but found #{typeof! people}.")

      cbk err
    return next err if err



    for k,v of @_people
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

class GitHubTrelloClient extends BitBucketTrelloClient

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
    throw 1 if !req.body.payload?
    msg = JSON.parse req.body.payload || '{}'
  catch
    msg = req.body.payload ? req.body

  console.log "[__POST__]".green, "by #{msg.user || msg.pusher?.name}".grey

  client = switch req.params.provider
  | "b"        => new BitBucketTrelloClient    body, msg
  | "g"        => new GitHubTrelloClient body, msg
  | otherwise  => null

  return res.json 404, error: "not found" if !client?

  acc = []
  msg.commits?.for-each? (i) -> acc.push -> client.handle-commit i, it
  async.series acc, (err)-> console.log err.toString!.red if err?

  res.json do
    req-body: body
    body: req.body
