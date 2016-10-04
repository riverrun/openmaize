# Openmaize with new Phoenix project

## Create new phoenix project

Run the following commands:

    mix phoenix.new alibaba
    cd alibaba

## Edit the database configuration

Edit the database configuration, changing the username and password in
the `config/dev.exs` and `config/test.exs` files.

If you have `sed` installed, you can do this by running the following commands:

    sed -i 's/username: "postgres"/username: "dev"/g' config/dev.exs config/test.exs
    sed -i 's/password: "postgres"/password: System.get_env("POSTGRES_PASS")/g' config/dev.exs config/test.exs

## Create the database

    mix ecto.create

## Add openmaize to deps and applications

1. Add openmaize to your `mix.exs` dependencies

    ```elixir
    defp deps do
      [{:openmaize, "~> 2.1"}]
    end
    ```

2. List `:openmaize` as an application dependency

    ```elixir
    def application do
      [applications: [:logger, :openmaize]]
    end
    ```

3. Run `mix do deps.get, compile`

# Create the Openmaize authorization and user model files

For a basic setup, run the following command:

    mix openmaize.gen.phoenixauth

If you want to add email confirmation and password resetting, add
the `--confirm` option:

    mix openmaize.gen.phoenixauth --confirm

There is also a `no-ecto` option if you are not using ecto and a
`no-html` option if you do not want to generate any html files.

## Run the database migration

    mix ecto.migrate

## Customize the Phoenix app and run tests

    mix test

You might need to run the `MIX_ENV=test mix ecto.drop` command if you
get a "users field already exists" error (when running the tests).
