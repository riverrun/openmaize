ExUnit.start()

redirect_pages = %{"admin" => "/admin", "user" => "/users"}
Application.put_env(:openmaize, :redirect_pages, redirect_pages)
