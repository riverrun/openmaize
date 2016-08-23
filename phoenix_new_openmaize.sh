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
mix phoenix.gen.html User users username:string password:string password_hash:string
# add `resources "/users", UserController` to web/router.ex - login and logout routes as well

# add openmaize to deps and applications
# generate authorization files
mix openmaize.gen.phoenixauth

# run migration
mix ecto.migrate
