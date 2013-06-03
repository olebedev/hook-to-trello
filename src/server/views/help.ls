require! {
  \optimist
  _:\prelude-ls
  \../../conf
}

exports.parse = (msg, separator=conf.separator) ->
  commit = [i.trim! for i in msg.split(separator)]
  s = (commit[1] || "") / //\s\-//
  f = [_.head s .trim!] ++ ["-#{i}".trim! for i in _.tail s]
  f = _.fold (++), [], [[s.trim! for s in i.match(/^\S+\s|.*/g) when !!s] for i in f]
  return do
    message: commit[0]
    options: optimist f .argv