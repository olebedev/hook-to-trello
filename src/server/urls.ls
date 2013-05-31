require! {
  \./views
}

exports.bind = (app)->
  app.get '/', views.public.main
  app.get "/:id", views.posthook
  app.post "/:id", views.posthook
    