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
# add `resources "/users", UserController` to web/router.ex
# add `field :password, :string, virtual: true` after running the above command

# run migration
mix ecto.migrate

#add openmaize to deps and applications

mix openmaize.gen.phoenixauth # login.html.eex build failed, undefined function form_for/4
mix openmaize.gen.ectodb

#now need further edits to web/models/user.ex - add `OpenmaizeEcto.add_password_hash`, etc.
