# Changelog

## v0.6.0

* Added an IdCheck module (plug).
* Removed function to provide optional checks from Authorize module.
* Storing `path` (full path) and `match` (matching a value in the Config.protected map)
variables in conn.private, which can be used in further checks.

## v0.5.0

* Split authentication and authorization into separate modules (plugs).
* Added a LoginoutCheck module (plug).
* Removed the global `Openmaize` plug.

## v0.4.0

* Added ability to use external function in final part of authorization.

## v0.3.0

* Added redirects: false option for use with apis.

## v0.2.0

* Can protect pages based on role.
* Redirects to login / home / role's page.
* Support for sending messages to phoenix flash.
* Support for signup, password hash checking and distribution of Json Web Tokens.
* Support for storage and checking of Json Web Tokens.
