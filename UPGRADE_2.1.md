# Upgrading to version 2.1

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 2.1"}

The main change is that the mix generators are now more powerful.

# Additional note about upgrading to version 2.0.2

If you are using `remember me`, the cookie generated with version
2.0.0 or 2.0.1 will be invalid in version 2.0.2, due to changes in
the Plug handling of the cryptographic keys. This will mean that
the users will have to log in again to generate a new `remember me`
cookie.

# Upgrading to version 2.0

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 2.0"}

## Using sessions for authentication instead of JWTs

If you want to use sessions for authentication, then you can remove
the `:openmaize_jwt` dependency.

If you want to use JWTs, you will need to use OpenmaizeJWT, which will
then install Openmaize as a dependency.

### Openmaize.Login and Openmaize.OnetimePass

These plugs now have fewer options.

Openmaize.Login has two options - `db_module` and `unique_id`

Openmaize.OnetimePass has one option for `db_module`, and it
also has options for the one-time passwords

### Openmaize.Logout has been removed

The `handle_logout` function in the Authorize module can handle the
process of logging out.

### Remember me

In the `web/router.ex` file, add the following line after the
call to Openmaize.Authenticate:

    plug Openmaize.Remember

You will also need to set a `remember_salt` value in the openmaize config.
See the documentation for `Openmaize.Remember.gen_salt` for more information.

### Change to the database module

In the Openmaize.Database behaviour and the MyApp.OpenmaizeEcto module,
the `find_user_byid` function has been renamed to `find_user_by_id`.

### Changes to the Authorize and Confirm module templates

The following changes have been made to the examples in the Authorize
and Confirm modules and tests:

`handle_login` in the Authorize module

  ```elixir
  def handle_login(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  def handle_login(%Plug.Conn{private: %{openmaize_otpdata: id}} = conn, _) do # this is only needed if you use two factor authentication
    render conn, "twofa.html", id: id
  end
  def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role, remember: true}}} = conn,
   %{"user" => %{"remember_me" => "true"}}) do # this is only needed if you use remember me functionality
    conn
    |> Openmaize.Remember.add_cookie(id)
    |> put_flash(:info, "You have been logged in")
    |> redirect(to: @redirects[role])
  end
  def handle_login(%Plug.Conn{private: %{openmaize_user: %{id: id, role: role}}} = conn, _params) do
    conn
    |> put_session(:user_id, id)
    |> put_flash(:info, "You have been logged in")
    |> redirect(to: @redirects[role])
  end
  ```

`handle_logout` in the Authorize module

  ```elixir
  def handle_logout(conn, _params) do
    configure_session(conn, drop: true)
    |> Openmaize.Remember.delete_rem_cookie # this line is only needed if you use remember me functionality
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: "/")
  end
  ```

`handle_reset` in the Confirm module

  ```elixir
  def handle_reset(%Plug.Conn{private: %{openmaize_error: message}} = conn,
   %{"user" => %{"email" => email, "key" => key}}) do
    conn
    |> put_flash(:error, message)
    |> render("reset_form.html", email: email, key: key)
  end
  def handle_reset(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn
    |> configure_session(drop: true)
    |> Openmaize.Remember.delete_rem_cookie # this line is only needed if you use remember me functionality
    |> put_flash(:info, message)
    |> redirect(to: "/login")
  end
  ```

`setup` in the Authorize test - you might need to add this to the other controller tests as well

  ```elixir
  setup %{conn: conn} do
    conn = conn |> bypass_through(MyApp.Router, :browser) |> get("/")
    user_conn = conn |> put_session(:user_id, 3) |> send_resp(:ok, "/")

    {:ok, %{conn: conn, user_conn: user_conn}}
  end
  ```

There are several other changes to the Authorize test. For more information,
see the files in the `priv/templates/html` directory and / or the example app at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).
