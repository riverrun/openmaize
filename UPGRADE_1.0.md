# Upgrading to version 1.0

Add the following to mix.exs:

    {:openmaize, "~> 1.0.0-beta.0"}

## Added mix generator to create an OpenmaizeEcto module

Most of the functions that interact with the database have been
moved outside Openmaize, but they are available as a separate
module which you can add to your app.

If you are using Ecto, run the following command:

    mix openmaize.gen.ectodb

This will create an OpenmaizeEcto module in the `web/models` directory.

## Added Openmaize.Database behaviour

If you are not using Ecto, or if you want to define your own
functions, you will need to create a module that implements
the Openmaize.Database behaviour. See the documentation for
the Openmaize.Database module for more details.

## Updating to Ecto 2.0.0 with Phoenix

Add the following to mix.exs:

    {:phoenix, "~> 1.1"}
    {:phoenix_ecto, "~> 3.0"}

And add the following to defp aliases:

    "test": ["ecto.create --quiet", "ecto.migrate", "test"]

Add the following to config/config.exs:

    config :my_app, ecto_repos: [MyApp.Repo]

Remove the following from test/test_helper.exs file:

    Mix.Task.run "ecto.create", ~w(-r <%= application_module %>.Repo --quiet)
    Mix.Task.run "ecto.migrate", ~w(-r <%= application_module %>.Repo --quiet)

In your test/test_helper.exs, replace the following:

    Ecto.Adapters.SQL.begin_test_transaction(MyApp.Repo)

with:

    Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)

Then, in each test/support/case.ex file, replace:

    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(MyApp.Repo, [])
    end

with:

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MyApp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, {:shared, self()})
    end

If using gettext, update errors.po and error_helper.ex view
