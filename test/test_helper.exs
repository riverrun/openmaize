ExUnit.start()

redirect_pages = %{"admin" => "/admin", "user" => "/users", nil => "/", "login" => "/admin/login"}
Application.put_env(:openmaize, :redirect_pages, redirect_pages)
