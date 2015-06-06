# Openmaize

Authentication library for Elixir

Openmaize is an authentication library for Elixir.
It is still under heavy development and has had limited testing
in production.

## Goals

Openmaize aims to provide developers the following:

* a secure, but lightweight, framework-agnostic authentication mechanism
that is easy to use.
* excellent documentation.

## Use

Before you use Openmaize, you need to make sure that your user model
contains an `id`, `name` and `role`.

You then need to configure Openmaize. For more information, see the documentation
for the Openmaize.Config module.

Next, add the following to the list of plugs you are using (in Phoenix, this
will be in `web/router.ex`):

    plug Openmaize

This will check the connection for a Json Web Token (JWT), and if there is
one and it is valid and the user's role is allowed to go to the url, then the
connection is allowed to go through. If there is no token, or if there is
an error, then the user will be redirected to the login page. If the login
is successful then the user will be given a token, which he / she can use
in subsequent requests.

There is an example of Openmaize being used with Phoenix at
[Openmaize-phoenix](https://github.com/riverrun/openmaize-phoenix).

### License

MIT
