defmodule Mix.Tasks.Openmaize.Gen.Apiauth do
  use Mix.Task

  def run(_args) do
    base_name = Mix.Openmaize.base_name
    Mix.Openmaize.copy_files(
      ["apiauth.ex", "web/controllers/auth.ex"],
      base: base_name)

    instructions = """

    The module #{base_name}.Auth has been installed to web/controllers/auth.ex

    """
    Mix.Shell.info instructions
  end

end
