# Upgrading to version 0.19

## Mix generator confirm option changed

When using the mix generator, `mix openmaize.gen.phoenixauth`, you will
be asked if you want to install the Confirm module and tests. The `--confirm`
option has been removed.

## Hashing algorithm (crypto_mod) configuration changed

The `crypto_mod` config value can now accept other hashing algorithms, not
just those offered by Comeonin. It has also been changed to be a module name
instead of an atom. If you have been using Pbkdf2, you need to change the
`crypto_mod` value from `:pbkdf2` to `Comeonin.Pbkdf2`.

## Changes to OpenmaizeJWT

OpenmaizeJWT is now version 0.10.

A `token_data` value has been added to the config. This lets you add
additional data to the token.

# Upgrading to version 0.18

## JWT-related code is now part of the OpenmaizeJWT package

Add the line {:openmaize_jwt, "~> 0.9"} to the deps and add `:openmaize_jwt`
to the list of applications in your mix.exs file if you want to continue using Openmaize as before.

Configuration for `token_alg`, `token_validity` and `keyrotate_days` is now
part of the `openmaize_jwt` config.

This change has been made to make it easier for developers to use other JSON Web Token libraries if they wish.

## Added support for two factor authentication

There is now support for checking one-time passwords, which can be used in two factor authentication.

If you want to use two factor authentication in your app, you need to add the following fields to your user schema:

```
    field :otp_required, :boolean
    field :otp_secret, :string
```

You can generate the otp_secret with the Comeonin.Otp.gen_secret function.

[This example app](https://github.com/riverrun/openmaize-phoenix) has an example
of using two factor authentication for certain users - see the `web/controllers/authorize.ex`
and `web/controllers/page_controller.ex` files for details..

## Small change to `authorize.ex` template

The following lines have been added to the `authorize.ex` html template (not for use with apis).
You only need to add these lines if you are using two factor authentication.

```
    def handle_login(%Plug.Conn{private: %{openmaize_otpdata: {storage, uniq, id}}} = conn, _) do
      render conn, "twofa.html", storage: storage, uniq: uniq, id: id
    end
```

# Upgrading to version 0.17

## `redirects` option has been removed

If you were letting Openmaize handle the redirects, you need to add functions
to handle these redirects in your web app. You can use the command
`mix openmaize.gen.phoenixauth` to generate an Authorize, and optionally,
a Confirm module, which can handle most of this functionality.

If you are developing an api or a SPA, you no longer need to set `[redirects: false]`
for any of the Openmaize plugs.

## AccessControl module (authorization plugs) has been removed

Authorization needs to be handled in your web app, but the `openmaize.gen.phoenixauth`
generator should help you handle most of your authorization needs. It will also
provide modules that are more easily customizable.

If you were using the `authorize` and `authorize_id` plugs before, you can have
the same functionality by running `mix openmaize.gen.phoenixauth` and then
making the following changes:

Import the Authorize module instead of `import Openmaize.AccessControl`.
Change `plug :authorize` to `plug :role_check`.
Change `plug :authorize_id` to `plug :id_check`.

There is also a custom action function in the Authorize module, which
might be more useful if you are checking the role for every route in
the controller.

## Moved `token_opts` option for Openmaize.Login to a global option in the config

If you were using the `token_opts` option with Openmaize.Login (to set the expiration
time of the token), you now need to set the `token_validity` option in the config
file.

## Changed confirmation function plugs to module plugs

Remove all references to the Openmaize.Confirm module.
Change `plug :confirm_email` calls to `plug Openmaize.ConfirmEmail`.
Change `plug :reset_password` calls to `plug Openmaize.ResetPassword`.

## Moved the `gen_token_link` function to the Openmaize.ConfirmEmail module

Change `Openmaize.ConfirmTools.gen_token_link` to `Openmaize.ConfirmEmail.gen_token_link`.

## Added a `password_strength` option to the config

This is used when setting or resetting the password.

## Added mix generators to create Authorize and Confirm modules

The command `mix openmaize.gen.phoenixauth` Authorize and Confirm modules
(with tests).

There are two options:

* api - use this if you are developing an api or SPA
* confirm - use this is you want functions for handling email confirmation

For example, run `mix openmaize.gen.phoenixauth --api` to generate an Authorize
module for an api. This will create the Authorize module in the web/controllers/authorize.ex
file, and it will also create a test in test/controllers/authorize_test.exs.
