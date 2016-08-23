defmodule <%= base %>.Router do
  use <%= base %>.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenmaizeJWT.Authenticate
  end

  scope "/api", <%= base %> do
    pipe_through :api

    post "/login", UserController, :login
    resources "/users", UserController
  end
end
