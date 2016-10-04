# Upgrading to version 2.1

Add the following to mix.exs and run `mix deps.update openmaize`:

    {:openmaize, "~> 2.1"}

The main change is that the mix generators are now more powerful,
so setting up new projects should be a lot easier.

# Additional note about upgrading to version 2.0.2

If you are using `remember me`, the cookie generated with version
2.0.0 or 2.0.1 will be invalid in version 2.0.2, due to changes in
the Plug handling of the cryptographic keys. This will mean that
the users will have to log in again to generate a new `remember me`
cookie.
