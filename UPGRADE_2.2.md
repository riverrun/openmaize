# Upgrading to version 2.2

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 2.2"}

## Database functions included in Openmaize

The database functions, which were in the openmaize_ecto.ex file, have
been moved to within the Openmaize library. This has the following effects:

* the openmaize_ecto.ex and openmaize_ecto_test.exs files are not needed
  * they can be deleted
* the `db_module` keyword argument, used by many plugs, has been replaced by
two arguments, `repo` and `user_model`
  * the defaults are MyApp.Repo for repo and MyApp.User for user_model
  * most developers will be unaffected by this change
* Ecto is no longer an optional dependency
