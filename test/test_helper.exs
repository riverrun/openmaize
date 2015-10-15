ExUnit.start()

protected = %{"/admin" => ["admin"], "/users" => ["admin", "user"], "/users/:id" => ["user"]}
Application.put_env(:openmaize, :protected, protected)
redirect_pages = %{"admin" => "/admin", "user" => "/users", nil => "/"}
Application.put_env(:openmaize, :redirect_pages, redirect_pages)
