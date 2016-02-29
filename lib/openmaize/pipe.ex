defmodule Openmaize.Pipe do
  @moduledoc """
  Customized pipe that exits if there is an error or if nil is
  returned.
  """

  defmacro error_pipe(pipes) do
    [{h,_}|t] = Macro.unpipe(pipes)
    Enum.reduce t, h, &check_error/2
  end

  defp check_error({x, pos}, acc) do
    quote do
      case unquote(acc) do
        {:error, message} -> {:error, message}
        nil -> nil
        acc -> unquote(Macro.pipe(acc, x, pos))
      end
    end
  end

end
