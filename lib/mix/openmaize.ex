defmodule Mix.Openmaize do
  @moduledoc """
  Helper functions for the mix generators.

  There are two mix generators available - `openmaize.gen.phoenixauth`
  and `openmaize.gen.ectodb`.
  See the documentation for Mix.Tasks.Openmaize.Gen.Phoenixauth and
  Mix.Tasks.Openmaize.Gen.Ectodb for more information.
  """

  @doc """
  Copy templates to the main app.
  """
  def copy_files(srcdir, files, mod_name) do
    for {source, target} <- files do
      contents = EEx.eval_file Path.join(srcdir, source), base: mod_name
      Mix.Generator.create_file target, contents
    end
  end
end
