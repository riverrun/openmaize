defmodule Mix.Openmaize.Phx.Generator do
  @moduledoc """
  Helper functions for the mix generators.

  There is one mix generator available - `openmaize.phx`.
  See the documentation for Mix.Tasks.Openmaize.phx.
  """

  @doc """
  Copy templates to the main app.
  """
  def copy_files(srcdir, files, opts) do
    for {format, source, target} <- files do
      contents = case format do
        :text -> File.read!(Path.join(srcdir, source))
        :eex  -> EEx.eval_file(Path.join(srcdir, source), opts)
      end
      Mix.Generator.create_file target, contents
    end
  end

  @doc """
  Get the mix project module name.
  """
  def base_module do
    base_name() |> Macro.camelize
  end

  @doc """
  Get the mix project name - as a string.
  """
  def base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string
  end

  @doc """
  Get the timestamp - used to create the migration file name.
  """
  def timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
