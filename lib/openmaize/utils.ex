defmodule Openmaize.Utils do
  @moduledoc """
  """

  def default_db do
    base_name() |> Module.concat(OpenmaizeEcto)
  end

  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string |> Macro.camelize
  end
end
