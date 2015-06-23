# Openmaize

Authentication and authorization library for Elixir

Openmaize is an authentication and authorization library for Elixir.
It is still under heavy development and has had limited testing
in production.

## Goals

Openmaize aims to provide developers the following:

* a secure, but lightweight, framework-agnostic authentication and authorization
mechanism that is easy to use.
* excellent documentation.

## Installation

1. Add openmaize to your `mix.exs` dependencies

  ```elixir
  defp deps do
    [ {:openmaize, "~> 0.4"} ]
  end
  ```

2. Run `mix do deps.get, compile`

## Use

Before you use Openmaize, you need to make sure that your user model
contains an `id` and `role`. You also need to have a unique key (name, email,
etc.) by which you identify the user. This is configurable, and the default
is name.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

There are three plugs available:

* Openmaize.LoginoutCheck
* Openmaize.Authenticate
* Openmaize.Authorize

There are also options to disable redirects and to use an external function
in the last part of the authorization.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

BSD
