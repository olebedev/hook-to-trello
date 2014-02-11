require! {
  \colors
  \request
  \optimist
  _:\prelude-ls
  \../../conf
}

exports.parse = (msg, separator=conf.separator) ->
  commit = [i.trim! for i in msg.split(separator)]
  s = (commit[1] || "") / //\s\-//
  f = [_.head s .trim!] ++ ["-#{i}".trim! for i in _.tail s]
  f = _.fold (++), [], [[s.trim! for s in i.match(/^\S+\s|.*/g) when !!s] for i in f]
  console.log "msg parser", msg, s, f, commit
  return do
    message: commit[0]
    options: optimist f .argv

exports.read-file = (url, next) ->
  
  if url.match(//http//)?
    err, resp, body <- request url
    console.log "fetch file from http".green, url.grey
    return next err, body

  fs.read-file url, next
