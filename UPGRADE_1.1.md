# Upgrading to version 1.1

Add the following to mix.exs:

    {:openmaize, "~> 1.1"}

## Using sessions for authentication instead of JWTs

Add db_module to Openmaize.Authenticate call - in `web/router.ex` file

authorize.ex and authorize_test.exs files need to be regenerated
(might need to change the name of the action function in the controller
files)



