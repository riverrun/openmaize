defmodule Openmaize.Password do
  @moduledoc """
  Check the password is valid, and optionally, check the password is
  strong enough.

  The functions in this module can be called directly, and they are
  also used by the Openmaize.ResetPassword plug.

  To perform the password strength checks, you need to have NotQwerty123
  installed.

  ## Basic checks

  The basic check just checks that the password is a string and that it
  is more than `min_length` characters long. The minimum length is 8
  characters by default.

  The following command is an example of how you can call `valid_password?`
  checking that the password is at least 12 characters long:

      Openmaize.Password.valid_password?(password, [min_length: 12])

  ## Password strength checks

  If you have NotQwerty123 installed, there are three options:

    * min_length - the minimum length of the password
    * extra_chars - check for punctuation characters (including spaces) and digits
    * common - check to see if the password is too common (too easy to guess)

  The default value for `min_length` is 8 characters if `extra_chars` is true,
  but 12 characters if `extra_chars` is false. This is because the password
  should be longer if the character set is restricted to upper and lower case
  letters.

  `extra_chars` and `common` are true by default.

      Openmaize.Password.valid_password?("verylongpassword", [min_length: 16, extra_chars: false])

  The above command will check that the password is at least 16 characters long and
  will skip the check for punctuation characters or digits.
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
