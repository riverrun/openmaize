# Upgrading to version 1.1

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 1.1"}

## Using sessions for authentication instead of JWTs

If you want to use sessions for authentication, then you can remove
the `:openmaize_jwt` dependency.

Add db_module to Openmaize.Authenticate call - in `web/router.ex` file

If you want to have a `remember me` functionality in your app, you
need to add `plug Openmaize.Remember, db_module: MyApp.OpenmaizeEcto`
to the pipeline in `web/router.ex`. Make sure that you run this
function after Openmaize.Authenticate.

The Openmaize.Login and Openmaize.OnetimePass plugs now have fewer
options.

The `authorize.ex` and `authorize_test.exs` files need to be regenerated
(might need to change the name of the action function in the controller
files) - also `confirm.ex` file a few changes



