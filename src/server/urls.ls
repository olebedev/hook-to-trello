require! {
  \./views
}

exports.bind = (app)->
  app.get '/', views.public.main
  app.post "/:provider/:id?", views.posthook
    