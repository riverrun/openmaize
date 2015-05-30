# Openmaize

Authentication library for Elixir -- work in progress

Openmaize is an authentication library for Elixir.
It is still under development and is not ready to use yet.

## Goals

Openmaize aims to provide developers the following:

* a secure, but lightweight, framework-agnostic authentication mechanism
that is easy to use, does not make you type a lot and stays out of your
way, but warns you if there are any errors.
* excellent documentation that extends beyond explaining the use of
the software and provides developers with information about best practices
and current research on matters related to the authentication of users.

## Scope

Openmaize will use the excellent password hashing library `comeonin` to
initially check the user and his/her password, and then for each page that needs
authentication, Json Web Tokens (JWT) will be used.

It will be possible to fine-tune authentication in the following ways:

* it can be based on action. For example, a regular user might be able to view
a page, but not be able to edit it.
* it can be based on user role or any other non-sensitive criteria.

### License

MIT
