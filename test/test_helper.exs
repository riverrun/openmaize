ExUnit.start()

Code.require_file "support/ecto_helper.exs", __DIR__

redirect_pages = %{"admin" => "/admin", "user" => "/users"}
Application.put_env(:openmaize, :redirect_pages, redirect_pages)
