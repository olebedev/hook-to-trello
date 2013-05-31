require! {
  \../../templates
}

exports.main = (req,res) ->
  res.send templates.base!