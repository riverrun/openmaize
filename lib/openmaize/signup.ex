defmodule Openmaize.Signup do
  @moduledoc """
  Module to create a user that can be authenticated using Openmaize.

  The `create_user` function hashes a password and adds the password
  hash to the database.

  There is also an option to check the strength of the password before
  it is hashed. To enable this option, add the optional dependency
  `{:not_qwerty123, "~> 1.0"}` to the `mix.exs` file.

  ## User model

  The example schema below is the most basic setup for Openmaize
  (:name and :password_hash are configurable):

      schema "users" do
        field :name, :string
        field :role, :string
        field :password, :string, virtual: true
        field :password_hash, :string

        timestamps
      end

  In the example above, the `:name` is used to identify the user. This can
  be set to any other value, such as `:email`. See the documentation for
  Openmaize.Login for details about logging in with a different value.

  The `:role` is needed for authorization, and the `:password` and the
  `:password_hash` fields are needed for the `create_user` function
  in this module (see the documentation for Openmaize.Config for information
  about changing :password_hash to some other value). Note the addition
  of `virtual: true` to the definition of the password field. This means
  that it will not be stored in the database.

  """

  import Ecto.Changeset
  alias Openmaize.Config

  if Code.ensure_loaded?(NotQwerty123) do
    defp add_pass_changeset(changeset, password, opts) do
      case NotQwerty123.PasswordStrength.strong_password?(password, opts) do
        true -> put_change(changeset, Config.hash_name, Config.get_crypto_mod.hashpwsalt(password))
        message -> add_error(changeset, :password, message)
      end
    end
  else
    defp add_pass_changeset(changeset, password, _opts) do
      put_change(changeset, Config.hash_name, Config.get_crypto_mod.hashpwsalt(password))
    end
  end

  @doc """
  Hash a password and add the hash to the database.

  Comeonin.Bcrypt is the default hashing function, but this can be changed to
  Comeonin.Pbkdf2 by setting the Config.get_crypto_mod value to :pbkdf2.

  ## Options

  The following options are available:

  * min_length - the minimum length of the password (default is 8 characters)
  * max_length - the maximum length of the password (default is 80 characters)

  These additional options are available if you have installed NotQwerty123:

  * extra_chars - check for punctuation characters (including spaces) and digits
  * common - check to see if the password is too common (easy to guess)

  See the documentation for NotQwerty123.PasswordStrength for more details about
  these options.

  ## Examples

  The following example first checks that the password is at least 12 characters
  long before hashing it:

      changeset
      |> Openmaize.Signup.create_user(params, [min_length: 12])

  """
  def create_user(changeset, params, opts \\ []) do
    {min_len, max_len} = {Keyword.get(opts, :min_length, 8), Keyword.get(opts, :max_length, 80)}
    changeset
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: min_len, max: max_len)
    |> put_pass_hash(opts)
  end

  @doc """
  Send a confirmation token by email.

  Send a confirmation token and add the token to the database. This
  function should be called after create_user.

  The second argument is `params`, and the third argument is for the
  mailing function you are going to use. This is a function that you
  need to provide.

  Add the following two entries to your user schema:

      field :confirmed, :boolean, default: false
      field :confirmation_token, :string

  ## Examples

  In the following example, the `Mailer.ask_confirm` function takes two
  arguments - the email address and the query link (everything after, but
  not including `?`).

      changeset
      |> Openmaize.Signup.add_confirm_token(params, &Mailer.ask_confirm/2)

  """
  def add_confirm_token(changeset, %{email: email}, func) do
    {key, link} = gen_token_link(email)
    func.(email, link)
    put_change(changeset, :confirmation_token, key)
  end

  defp gen_token_link(email) do
    key = :crypto.strong_rand_bytes(24) |> Base.url_encode64
    {key, "email=#{URI.encode_www_form(email)}&key=#{key}"}
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true,
                     changes: %{password: password}} = changeset, opts) do
    add_pass_changeset(changeset, password, opts)
  end
  defp put_pass_hash(changeset, _opts), do: changeset
end
