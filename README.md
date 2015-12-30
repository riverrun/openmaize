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
    [ {:openmaize, "~> 0.11"} ]
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
contains an `id` and a `role`. You will also need a `unique_id`, such
as `name`, `email` or `username`, for the user. The default `unique_id`
is `name`, but you can change this in the config.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

Openmaize provides the following plugs:

* Openmaize.Authenticate
    * authenticates the user
    * sets (adds to the assigns map) the current_user variable
* Openmaize.AccessControl.authorize
    * check, based on the user's role, to see if the user is authorized to access the page
* Openmaize.AccessControl.authorize_id
    * check, based on user id, to see if the user is authorized to access the page
* Openmaize.Login
    * handle login POST request
* Openmaize.Logout
    * handle logout request

See the relevant module documentation for more details.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

BSD
