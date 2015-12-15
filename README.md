# Openmaize

Authentication and authorization library for Elixir

## Goals

Openmaize is an authentication and authorization library that aims to be:

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
    [ {:openmaize, "~> 0.9"} ]
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

Before you use Openmaize, you need to make sure that your user model
contains an `id`, `name` (which identifies the user) and `role`.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

Openmaize provides the following main plugs:

* Openmaize.LoginoutCheck
  * checks the path to see if it is for the login or logout page
  * handles login or logout if necessary
* Openmaize.Authenticate
  * authenticates the user
  * sets (adds to the assigns map) the current_user variable

There are also plugs that can be used for authorization in the
Openmaize.AccessControl module.

See the relevant module documentation for more details.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

BSD
