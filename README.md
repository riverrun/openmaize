# Openmaize [![Build Status](https://travis-ci.org/riverrun/openmaize.svg?branch=master)](https://travis-ci.org/riverrun/openmaize) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/riverrun/openmaize.svg)](https://beta.hexfaktor.org/github/riverrun/openmaize)

Authentication library for Elixir

## Upgrading to the newest version

There have been a few changes in the newest versions, 1.0.0-beta.
Please check the `UPGRADE_1.0.md` guide in this directory for details.

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
    [ {:openmaize, "~> 1.0.0-beta"} ]
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

Before you use Openmaize, you need to make sure that you have a module
that implements the Openmaize.Database behaviour. If you are using Ecto,
you can generate the necessary files by running the following command:

    mix openmaize.gen.ectodb

To generate modules to handle authorization, and optionally email confirmation,
run the following command:

    mix openmaize.gen.phoenixauth

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

Openmaize provides the following functionality:

### Authentication

* Openmaize.Authenticate - plug to authenticate users, using JSON Web Tokens.
* Openmaize.Login - plug to handle login POST requests.
* Openmaize.Logout - plug to handle logout requests.

## Email confirmation and password resetting

* Openmaize.ConfirmEmail - verify the token that was sent to the user by email.
* Openmaize.ResetPassword - verify the token that was sent to the user by email,
but this time so that the user's password can be reset.

See the relevant module documentation for more details.

## Using with Phoenix

You can generate an example Authorize module and / or a Confirm module
by running the command `mix openmaize.gen.phoenixauth`.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

BSD
