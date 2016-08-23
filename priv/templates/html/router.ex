defmodule <%= base %>.Router do
  use <%= base %>.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Openmaize.Authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", <%= base %> do
    pipe_through :browser

    get "/", PageController, :index
    get "/login", PageController, :login, as: :login
    post "/login", PageController, :login_user, as: :login
    delete "/logout", PageController, :logout, as: :logout

    resources "/users", UserController
  end

end
