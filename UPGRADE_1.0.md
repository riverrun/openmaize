# Upgrading to version 1.0

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
