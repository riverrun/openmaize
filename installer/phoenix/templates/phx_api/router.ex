defmodule <%= base %>.Router do
  use <%= base %>.Web, :router

  import <%= base %>.Auth

  pipeline :api do
    plug :accepts, ["json"]
    plug :verify_token
  end

  scope "/api", <%= base %> do
    pipe_through :api

    post "/sessions/create", SessionController, :create
    resources "/users", UserController, except: [:new, :edit]<%= if confirm do %>
    get "/sessions/confirm_email", SessionController, :confirm_email
    post "/password_resets/create", PasswordResetController, :create
    put "/password_resets/update", PasswordResetController, :update<% end %>
  end
end
