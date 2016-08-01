# Upgrading to version 1.1

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 1.1"}

## Using sessions for authentication instead of JWTs

If you want to use sessions for authentication, then you can remove
the `:openmaize_jwt` dependency.

If you want to use JWTs, you will need to use OpenmaizeJWT, which will
then install Openmaize as a dependency.

### Openmaize.Authenticate

In the `web/router.ex` file, add the `db_module` option to Openmaize.Authenticate:

    plug Openmaize.Authenticate, db_module: MyApp.OpenmaizeEcto

### Remember me

In the `web/router.ex` file, add the following line after the
call to Openmaize.Authenticate:

    plug Openmaize.Remember, db_module: MyApp.OpenmaizeEcto

You will also need to set a `remember_salt` value in the openmaize config.
See the documentation for `Openmaize.Remember.gen_salt` for more information.

### Openmaize.Login and Openmaize.OnetimePass

These plugs now have fewer options.

Openmaize.Login has two options - `db_module` and `unique_id`

Openmaize.OnetimePass has one option for `db_module`, and it
also has options for the one-time passwords

### Openmaize.Logout has been removed

The `handle_logout` function in the Authorize module can handle the
process of logging out.

### Changes to the Authorize and Confirm module templates

The following changes have been made:

`handle_login` in the Authorize module
`handle_logout` in the Authorize module
`handle_reset` in the Confirm module
`setup` in the Authorize test - you might need to add this to the other controller tests as well

For more information, see the examples at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).
