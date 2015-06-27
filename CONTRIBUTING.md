# Contributing to Openmaize

This is a draft.

## Features

* checks for login / logout pages and handles these calls
* authenticates users using Json Web Tokens
* checks to see if the user is allowed to access the page / resource
* provides excellent documentation
* is framework-agnostic
* is lightweight

## Experimental features

* allows the developer to define a function to perform extra authorization checks

This experimental feature is designed to make Openmaize authorization a lot
more configurable and fine-grained. We might well decide on a different approach
to this problem in the future.

## Things we do not intend to implement

* email confirmation
* password reset

At the moment, we feel that these problems are best left outside the remit
of this library. However, if you can convince us that they are necessary,
we will be glad to implement them.

## Ways you can contribute

* Find bugs
* Help support more database adapters when making the Ecto query
* Add to, or improve, the documentation
* Add further optional checks that you think might be useful
