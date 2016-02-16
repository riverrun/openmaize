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
    [ {:openmaize, "~> 0.14"} ]
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
configured correctly. See the documentation for Openmaize.Signup for details.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

It provides the following functionality:

### Authentication

* Openmaize.Authenticate - plug to authenticate users, using Json Web Tokens.
* Openmaize.Login - plug to handle login POST requests.
* Openmaize.Logout - plug to handle logout requests.

### Authorization

In the Openmaize.AccessControl module:

* authorize - verify that the user, based on user role, is authorized to
access the requested page.
* authorize_id - verify that the user, based on the user id, is authorized to
access the requested page.

### User creation helper functions

In the Openmaize.Signup module:

* create_user - take an Ecto changeset, check that the password is valid,
and return an updated changeset.
* add_confirm_token - add a confirmation token to the changeset.
* gen_token_link - generate a confirmation token and a link to be used in
the confirmation url that is sent to the user.

In the Openmaize.Confirm module:

* confirm_email - verify the token that was sent to the user by email.
* reset_password - like `confirm_email`, verify the token that was sent
to the user by email, but this time so that the user's password can be reset.

See the relevant module documentation for more details.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

BSD
