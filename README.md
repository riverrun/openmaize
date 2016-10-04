# Openmaize [![Build Status](https://travis-ci.org/riverrun/openmaize.svg?branch=master)](https://travis-ci.org/riverrun/openmaize) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/riverrun/openmaize.svg)](https://beta.hexfaktor.org/github/riverrun/openmaize)

Authentication library for Plug-based applications in Elixir

## Upgrading to the newest version

Please check the `UPGRADE_2.1.md` guide in this directory for details.

## Goals

Openmaize is an authentication library that aims to be:

* secure
* lightweight
* easy to use
* well documented

It should work with any application that uses Plug, but it has only been
tested with the Phoenix Web Framework.

## Installation

1. Add openmaize to your `mix.exs` dependencies

    ```elixir
    defp deps do
      [{:openmaize, "~> 2.1"}]
    end
    ```

2. List `:openmaize` as an application dependency

    ```elixir
    def application do
      [applications: [:logger, :openmaize]]
    end
    ```

3. Run `mix do deps.get, compile`

## Use

To set up user authorization in a new Phoenix app, run the following command:

    mix openmaize.gen.phoenixauth

See the `phoenix_new_openmaize.md` file for details about all the available
options.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

## Migrating from Devise

After running the command `mix openmaize.gen.phoenixauth`, add the
following lines to the config file:

    config :openmaize,
      hash_name: :encrypted_password

You might also need to add `unique_id: :email` to the Openmaize.Login
call - see the documentation for Openmaize.Login for more details.

## Openmaize plugs

  * Authentication
    * Openmaize.Authenticate - plug to authenticate users, using sessions.
    * Openmaize.Login - plug to handle login POST requests.
    * Openmaize.OnetimePass - plug to handle one-time password POST requests.
    * Openmaize.Remember - plug to check for a `remember me` cookie.
  * Email confirmation and password resetting
    * Openmaize.ConfirmEmail - verify the token that was sent to the user by email.
    * Openmaize.ResetPassword - verify the token that was sent to the user by email,
    but this time so that the user's password can be reset.

See the relevant module documentation for more details.

### License

BSD
