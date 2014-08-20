require! {
  \colors
  \request
  \optimist
  _:\prelude-ls
  \../../conf
  \fs
}

# { id: '51ac788907d835ca22001f19',
#        name: 'Doing',
#        closed: false,
#        idBoard: '51ac788907d835ca22001f17',
#        pos: 32768,
#        subscribed: false }

exports.parse = (list, msg) ->
  # commit = [i.trim! for i in msg.split(separator)]
  # s = (commit[1] || "") / //\s\-//
  # f = [_.head s .trim!] ++ ["-#{i}".trim! for i in _.tail s]
  # f = _.fold (++), [], [[s.trim! for s in i.match(/^\S+\s|.*/g) when !!s] for i in f]
  # return do
  #   message: commit[0]
  #   options: optimist f .argv

  commit = {}
  hash = msg.match /#\d+/
  return commit if !hash?

  hash .= pop!
  commit.card = +hash.slice(1)
  prefix = ("" + msg).slice(0, msg.search(/#\d+/)).trim!to-lower-case!

  for item in list
    if prefix.match(new RegExp(item.name.to-lower-case! + "$", \i))?
      commit.list = item.id
      return commit

  return commit

exports.read-file = (url, next) ->
  if url.match(//http//)?
    err, resp, body <- request url
    try body = JSON.parse body
    return next err, body

  else
    err, body <~ fs.read-file url
    try body = JSON.parse body
    return next err, body