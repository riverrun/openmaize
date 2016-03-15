# Openmaize

Authentication library for Elixir

## Upgrading to version 0.17

There have been many changes in the new version, 0.17.
Please check the `UPGRADE_0.17.md` guide in this directory for details.

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
    [ {:openmaize, "~> 0.17"} ]
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

Before you use Openmaize, you need to make sure that your user model is
configured correctly. See the documentation for Openmaize.DB for details.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

It provides the following functionality:

### Authentication

* Openmaize.Authenticate - plug to authenticate users, using JSON Web Tokens.
* Openmaize.Login - plug to handle login POST requests.
* Openmaize.Logout - plug to handle logout requests.

## Email confirmation and password resetting

* Openmaize.ConfirmEmail - verify the token that was sent to the user by email.
* Openmaize.ResetPassword - verify the token that was sent to the user by email,
but this time so that the user's password can be reset.

## Various helper functions

In the Openmaize.DB module:

* add_password_hash - take an Ecto changeset, hash the password and add the
password hash to the changeset.
* add_confirm_token - add a confirmation token to the changeset.
* add_reset_token - add a reset token to the changeset.

See the relevant module documentation for more details.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

BSD
