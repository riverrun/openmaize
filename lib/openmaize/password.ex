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
  is more than a certain amount of characters long, 8 characters by default.

  The following command is an example of how you can call `valid_password?`
  checking that the password is at least 12 characters long:

      Openmaize.Password.valid_password?(password, 12)

  ## Password strength checks

  If you have NotQwerty123 installed, in addition to the minimum length
  check, the password check will verify that the password is not similar
  to any word in a customizable common passwords list. See the documentation
  for NotQwerty123 for more details.

  """

  if Code.ensure_loaded?(NotQwerty123) do

    def valid_password?(password, min_len \\ 8)
    def valid_password?(password, min_len) when is_binary(password) do
      case NotQwerty123.PasswordStrength.strong_password?(password, min_length: min_len) do
        true -> {:ok, password}
        message -> {:error, message}
      end
    end
    def valid_password?(_, _), do: {:error, "The password should be a string"}

  else

    def valid_password?(password, min_len \\ 8)
    def valid_password?(password, min_len) when is_binary(password) do
      String.length(password) >= min_len and
        {:ok, password} || {:error, "The password is too short. At least #{min_len} characters."}
    end
    def valid_password?(_, _), do: {:error, "The password should be a string"}

  end
end
