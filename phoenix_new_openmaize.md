# Openmaize with new Phoenix project

## Create new phoenix project

Run the following commands (replace alibaba with the name of your project):

    mix phoenix.new alibaba
    cd alibaba

## Edit the database configuration

Edit the database configuration, changing the username and password in
the `config/dev.exs` and `config/test.exs` files.

If you have `sed` installed, you can do this by running the following commands:

    sed -i 's/username: "postgres"/username: "dev"/g' config/dev.exs config/test.exs
    sed -i 's/password: "postgres"/password: System.get_env("POSTGRES_PASS")/g' config/dev.exs config/test.exs

## Add openmaize to deps and applications

1. Add openmaize to your `mix.exs` dependencies

    ```elixir
    defp deps do
      [{:openmaize, "~> 2.2"}]
    end
    ```

2. List `:openmaize` as an application dependency

    ```elixir
    def application do
      [applications: [:logger, :openmaize]]
    end
    ```

3. Run `mix deps.get`

# Create the Openmaize authorization and user model files

For a basic setup, run the following command:

    mix openmaize.gen.phoenixauth

If you want to add email confirmation and password resetting, add
the `--confirm` option:

    mix openmaize.gen.phoenixauth --confirm

There is also a `no-html` option if you do not want to generate any html files.

## Create the database and run the migration

    mix ecto.setup

## Customize the Phoenix app

If you ran the `mix openmaize.gen.phoenixauth` command with the
`--confirm` option, you will need to edit the `lib/name_of_your_project/mailer.ex`
file, using an email library of your choice.

To see which routes are available, you can run `mix phoenix.routes`,
and to start the server, run `mix phoenix.server`. For tests, run
`mix test`.
