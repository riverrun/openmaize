defmodule <%= base %>.Router do
  use <%= base %>.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenmaizeJWT.Authenticate
  end

  scope "/api", <%= base %> do
    pipe_through :api

    resources "/users", UserController
    resources "/sessions", SessionController, only: [:create, :delete]<%= if confirm do %>
    get "/sessions/confirm_email", SessionController, :confirm_email
    resources "/password_resets", PasswordResetController, only: [:create, :update]<% end %>
  end
end
