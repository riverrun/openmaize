#!/bin/sh

# create new phoenix project and cd into it
mix phoenix.new alibaba
cd alibaba

# edit the database configuration
sed -i 's/username: "postgres"/username: "dev"/g' config/dev.exs config/test.exs
sed -i 's/password: "postgres"/password: System.get_env("POSTGRES_PASS")/g' config/dev.exs config/test.exs

# create the database
mix ecto.create

# create user model - with templates and controller
# basic
#mix phoenix.gen.html User users username:string password_hash:string
# with confirmation
mix phoenix.gen.html User users username:string email:string password_hash:string \
    confirmed_at:datetime confirmation_token:string confirmation_sent_at:datetime \
    reset_token:string reset_sent_at:datetime
# add `field :password, :string, virtual: true` to the user model
# add `auth_changeset` and `reset_changeset` to the user model

# add openmaize to deps and applications
# generate authorization files
mix openmaize.gen.phoenixauth

# run migration
#mix ecto.migrate

# replace `password_hash` in the tests / templates with `password`

