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
  def copy_files(srcdir, files, opts) do
    for {format, source, target} <- files do
      contents = case format do
        :text -> File.read!(Path.join(srcdir, source))
        :eex  -> EEx.eval_file(Path.join(srcdir, source), opts)
      end
      Mix.Generator.create_file target, contents
    end
  end
end
