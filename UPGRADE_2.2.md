# Upgrading to version 2.2

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 2.2"}

## Database functions included in Openmaize

The database functions, which were in the openmaize_ecto.ex file, have
been moved to within the Openmaize library.

Most users just need to make the following changes:

* delete `web/models/openmaize_ecto.ex` and `test/models/openmaize_ecto_test.exs`
  * these are no longer needed
* replace every reference to OpenmaizeEcto with Openmaize.Database in `web/models/user.ex`

If you are using non-standard names for the database repo and user model,
you need to be aware of the following:

* the `db_module` keyword argument, used by many plugs, has been replaced by
two arguments, `repo` and `user_model`
  * the defaults are MyApp.Repo for repo and MyApp.User for user_model
  * most developers will be unaffected by this change

Finally, Ecto is now a hard dependency - it is no longer optional.
