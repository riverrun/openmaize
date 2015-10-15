defmodule Openmaize.Utils do
  @moduledoc """
  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro left &&& right do
    quote do
      case unquote(left) do
        {:error, message} -> {:error, message}
        _ -> unquote(right)
      end
    end
  end

  defmacro left ||| right do
    quote do
      case unquote(left) do
        {:error, message} -> unquote(right)
        x -> x
      end
    end
  end

  defmacro left <|> right do
    quote do
      case unquote(left) do
        {:error, message} -> {:error, message}
        _ -> unquote(left) |> unquote(right)
      end
    end
  end

end
