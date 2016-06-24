# Upgrading to version 1.0

Add the following to mix.exs:

    {:openmaize, "~> 1.0.0-beta"}

## Added mix generator to create an OpenmaizeEcto module

Most of the functions that interact with the database have been
moved outside Openmaize, but they are available as a separate
module which you can add to your app.

If you are using Ecto, run the following command:

    mix openmaize.gen.ectodb

This will create an OpenmaizeEcto module in the `web/models` directory.

In addition, you will need to replace every reference to `Openmaize.DB`
in your project with `MyApp.OpenmaizeEcto`.

## Added Openmaize.Database behaviour

If you are not using Ecto, or if you want to define your own
functions, you will need to create a module that implements
the Openmaize.Database behaviour. See the documentation for
the Openmaize.Database module for more details.

## Updating to Phoenix 1.2 and Ecto 2.0

Openmaize requires Ecto 2.0, and I recommend that you also update Phoenix
to version 1.2.

Follow [these instructions](https://gist.github.com/chrismccord/29100e16d3990469c47f851e3142f766)
to update to Phoenix 1.2 and Ecto 2.0.
