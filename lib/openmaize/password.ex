defmodule Openmaize.Password do
  @moduledoc """
  Check the password is valid, and optionally, check the password is
  strong enough.

  The functions in this module can be called directly, and they are
  also used by the Openmaize.ResetPassword plug.

  To perform the more advanced password strength checks, you need to
  have NotQwerty123 installed.

  ## Basic checks

  The basic check just checks that the password is a string and that it
  is more than `min_length` characters long. The minimum length is 8
  characters by default.

  The following command is an example of how you can call `valid_password?`
  checking that the password is at least 12 characters long:

      Openmaize.Password.valid_password?(password, [min_length: 12])

  ## Password strength checks

  If you have NotQwerty123 installed, there is one option:

    * min_length - the minimum length of the password

  The default value for `min_length` is 8 characters.

      Openmaize.Password.valid_password?("verylongpassword", [min_length: 16])

  The above command will check that the password is at least 16 characters long.
  """

  if Code.ensure_loaded?(NotQwerty123) do

    def valid_password?(password, opts) when is_binary(password) do
      case NotQwerty123.PasswordStrength.strong_password?(password, opts) do
        true -> {:ok, password}
        message -> {:error, message}
      end
    end
    def valid_password?(_, _), do: {:error, "The password should be a string"}

  else

    def valid_password?(password, opts) when is_binary(password) do
      min_length = Keyword.get(opts, :min_length, 8)
      String.length(password) >= min_length and
        {:ok, password} || {:error, "The password is too short. At least #{min_length} characters."}
    end
    def valid_password?(_, _), do: {:error, "The password should be a string"}

  end
end
