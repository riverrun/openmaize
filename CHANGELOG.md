# Changelog

## v0.10.2

* Enhancements
    * Added unique_id config value, so it's possible to use `email`, or anything else, instead of `name` to identify the user.

## v0.10.0

* Changes
    * Removed deprected functions (Authorize and AuthorizeIdCheck modules).
    * Removed check for protected page in Authenticate module.

## v0.9.0

* Enhancements
    * Added more lightweight authorization function plugs in the AccessControl module.
* Deprecations
    * Authorize and AuthorizeIdcheck module plugs.
        * These will be removed in version 0.10.
        * The functions in the AccessControl module can be used instead.

## v0.8.0

* Enhancements
    * Added keymanager to rotate keys on a periodical basis.
* Changes
    * Removed `token_info` and `token_validity` config values.
    * Added `token_validity` option to LoginoutCheck plug.
    * Changed default structure of tokens.
    * Removed Joken dependency.

## v0.7.0

* Changes
    * Reorganized authorization code so that the id_check calls the basic Authorize check before checking ids.
    * Updated to new version of Plug (replaced `full_path` with `Plug.Conn.request_path`).
    * Stopped using compile time configuration.

## v0.6.0

* Enhancements
    * Added an IdCheck module (plug).
    * Storing `path` (full path) and `match` (matching a value in the Config.protected map)
    variables in conn.private, which can be used in further checks.
* Changes
    * Removed function to provide optional checks from Authorize module.

## v0.5.0

* Enhancements
    * Split authentication and authorization into separate modules (plugs).
    * Added a LoginoutCheck module (plug).
* Changes
    * Removed the global `Openmaize` plug.

## v0.4.0

* Enhancements
    * Added ability to use external function in final part of authorization.

## v0.3.0

* Enhancements
    * Added redirects: false option for use with apis.

## v0.2.0

* Enhancements
    * Protect pages based on role.
    * Redirects to login / home / role's page.
    * Support for sending messages to phoenix flash.
    * Support for signup, password hash checking and distribution of Json Web Tokens.
    * Support for storage and checking of Json Web Tokens.
