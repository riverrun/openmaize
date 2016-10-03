#!/bin/sh

# create new phoenix project and cd into it
mix phoenix.new alibaba
cd alibaba

# edit the database configuration
sed -i 's/username: "postgres"/username: "dev"/g' config/dev.exs config/test.exs
sed -i 's/password: "postgres"/password: System.get_env("POSTGRES_PASS")/g' config/dev.exs config/test.exs

# create the database
mix ecto.create

# add openmaize to deps and applications
# generate authorization and user model files
# add `--confirm` option if you want email confirmation / password resetting
# add `--no-ecto` option if you are not using ecto
mix openmaize.gen.phoenixauth
#mix openmaize.gen.phoenixauth --confirm

# run migration
mix ecto.migrate

# run tests
mix test
