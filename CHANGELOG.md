# Changelog

## v2.8.0-dev

* Enhancements
    * Made Login, ConfirmEmail and ResetPassword modules more configurable

## v2.7.0

* Enhancements
    * Moved generator to separate installer - `openmaize.phx`

## v2.6.0

* Enhancements
    * Added option to change the unique_id when using the phoenixauth generator

## v2.5.0

* Enhancements
    * Added `--api --confirm` option for the phoenixauth generator

## v2.4.0

* Enhancements
    * Added basic `--api` option for the phoenixauth generator

## v2.3.0

* Bug fixes
    * Added database lock to HOTP update function

## v2.2.0

* Changes
    * Moved the database functions to within Openmaize
        * The openmaize_ecto and openmaize_ecto_test files are no longer needed and can be deleted
    * Replaced `db_module` setting (used in several plugs) with `repo` and `user_model`

## v2.1.0

* Enhancements
    * Mix generators create more files, make more changes, and are smarter
* Bug fixes
    * Changed TOTP implementation to not allow a token to be used again
* Changes
    * Added default value for `db_module` (used in several plugs)

## v2.0.0

* Changes
    * Now using sessions (provided by Plug) for authentication, instead of JSON Web Tokens
        * Authentication using JSON Web Tokens will be handled by OpenmaizeJWT, a separate library
    * Changed default expiry time for the ConfirmEmail and ResetPassword modules to one hour
    * Changed how `remember_me` is implemented

## v1.0.0

* Enhancements
    * Added a mix generator to generate an OpenmaizeEcto module.
        * This module implements the Openmaize.Database behaviour.
* Changes
    * Moved the Config.db_module functionality to using keyword arguments
        * This affects the Openmaize.Login, Openmaize.OnetimePass,
        Openmaize.ConfirmEmail and Openmaize.ResetPassword plugs.
    * Removed the Openmaize.DB module.
    * Added the Openmaize.Database behaviour.

## v0.19.0

* Changes
    * Made it possible to override default token validity - can be used to implement `remember_me` functionality.
    * Added `token_data` config option to OpenmaizeJWT. This allows the developer to add extra data to the token.
    * Changed the way the confirm option is handled in the mix generator.
    * Changed the config value for `crypto_mod`.
        * It is now a module name, not an atom, and other algorithms, not just Comeonin, can be used.

## v0.18.0

* Enhancements
    * Added one-time password support for use in two factor authentication.
* Changes
    * Moved the JSON Web Token specific code to separate library, OpenmaizeJWT, which is now an optional dependency.

## v0.17.0

* Enhancements
    * Added mix generators to generate an Authorize, and optionally, a Confirm module.
    * Added `password_strength` value to the config - to be used when setting or resetting the password.
* Changes
    * Removed all the `redirects` options.
    * Removed authorization module.
    * Added `password_strength` value to the config - to be used when setting or resetting the password.
    * Changed `token_opts` option in the Login module to a global `token_validity` option in the config.
    * Moved `confirm_email` function plug to `Openmaize.ConfirmEmail` module plug.
    * Moved `reset_password` function plug to `Openmaize.ResetPassword` module plug.
    * Moved `gen_token_link` function to the Openmaize.ConfirmEmail module.

## v0.16.0

* Changes
    * Reduced JWT expiry and confirmation token validity / expiry time to 2 hours.
    * Made Ecto an optional dependency.
    * Changed the name of the Openmaize.Signup module to Openmaize.DB.
        * All of the database-related functions are now in the Openmaize.DB module.
        * You can use a different module by changing the `db_module` in the config.
    * In the Openmaize.DB module, replaced the `create_user` function with the `add_password_hash` function.
    * Brought back NotQwerty123 optional dependency.
    * Moved the `gen_token_link` function to the Openmaize.ConfirmTools module.

## v0.15.0

* Enhancements
    * Added 'multiple unique ids' - the user can log in with username or email, or email or phone, etc.
* Changes
    * Changed default unique_id from :name to :username.

## v0.14.0

* Enhancements
    * Added tools to handle resetting the password.
* Changes
    * Changed the way the email confirmation is called.
    * Removed the optional password strength checker.

## v0.13.0

* Enhancements
    * Added tools to handle email confirmation.
* Changes
    * Made password_hash value configurable.

## v0.12.0

* Enhancements
    * Added option to call custom function to access the database with Openmaize.Login.
* Changes
    * Moved the unique_id config value to an option for the Openmaize.Login login function.
* Bug fixes
    * Fixed the bug with unique_id being set to name in the generate_token funcion.

## v0.11.0

* Enhancements
    * Added unique_id config value, so it's possible to use `email`, or anything else, instead of `name` to identify the user.
    * Added check for confirmed email to the login.
* Changes
    * Replaced LoginoutCheck with Login and Logout plugs, so now no check is done for login / logout path.

## v0.10.0

* Changes
    * Removed deprected functions (Authorize and AuthorizeIdCheck modules).
    * Removed check for protected page in Authenticate module.

## v0.9.0

* Enhancements
    * Added more lightweight authorization function plugs in the AccessControl module.
* Deprecations
    * Authorize and AuthorizeIdcheck module plugs.
        * These will be removed in version 0.10.
        * The functions in the AccessControl module can be used instead.

## v0.8.0

* Enhancements
    * Added keymanager to rotate keys on a periodical basis.
* Changes
    * Removed `token_info` and `token_validity` config values.
    * Added `token_validity` option to LoginoutCheck plug.
    * Changed default structure of tokens.
    * Removed Joken dependency.

## v0.7.0

* Changes
    * Reorganized authorization code so that the id_check calls the basic Authorize check before checking ids.
    * Updated to new version of Plug (replaced `full_path` with `Plug.Conn.request_path`).
    * Stopped using compile time configuration.

## v0.6.0

* Enhancements
    * Added an IdCheck module (plug).
    * Storing `path` (full path) and `match` (matching a value in the Config.protected map)
    variables in conn.private, which can be used in further checks.
* Changes
    * Removed function to provide optional checks from Authorize module.

## v0.5.0

* Enhancements
    * Split authentication and authorization into separate modules (plugs).
    * Added a LoginoutCheck module (plug).
* Changes
    * Removed the global `Openmaize` plug.

## v0.4.0

* Enhancements
    * Added ability to use external function in final part of authorization.

## v0.3.0

* Enhancements
    * Added redirects: false option for use with apis.

## v0.2.0

* Enhancements
    * Protect pages based on role.
    * Redirects to login / home / role's page.
    * Support for sending messages to phoenix flash.
    * Support for signup, password hash checking and distribution of JSON Web Tokens.
    * Support for storage and checking of JSON Web Tokens.
