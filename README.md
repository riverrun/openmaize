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
    [ {:openmaize, "~> 0.5"} ]
  end
  ```

2. Run `mix do deps.get, compile`

## Use

Before you use Openmaize, you need to make sure that your user model
contains an `id`, `name` (which identifies the user) and `role`.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

Openmaize provides the following plugs:

* Openmaize.LoginoutCheck
    * checks the path to see if it is for the login or logout page
    * handles login or logout if necessary
* Openmaize.Authenticate
    * authenticates the user
    * sets (adds to the assigns map) the current_user variable
* Openmaize.Authorize
    * checks to see if the user is authorized to access the page / resource

See the relevant module documentation for more details.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

## TODO

[] Support more database adapters when making Ecto query
    * we only support postgres at the moment
[] Add customizable unique identifier for user model
    * currently the identifier is name -- allow developers to customize this
    * planned for when Erlang 18 is more widely adopted, as Erlang 18 supports variables as Map keys

The Authorize module allows the developer to define functions that can be used
to perform further authorization checks (see the Openmaize.IdCheck
module for examples of these functions). We would like to implement more
of these checks, based on developer feedback.

### License

BSD
