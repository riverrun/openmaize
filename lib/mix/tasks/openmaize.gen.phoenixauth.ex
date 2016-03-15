defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  @moduledoc """
  Create modules for authorization and email confirmation.
  """

  def run(args) do
    switches = [api: :boolean, confirm: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    mod_name = Mix.Openmaize.base_name
    srcdir = Path.join [Application.app_dir(:openmaize, "priv"), "templates",
                        opts[:api] && "api" || "html"]

    files = [{"authorize.ex", "web/controllers/authorize.ex"},
             {"authorize_test.exs", "test/controllers/authorize_test.exs"}]
    if opts[:confirm] do
      files = files ++ [{"confirm.ex", "web/controllers/confirm.ex"},
                        {"confirm_test.exs", "test/controllers/confirm_test.exs"}]
    end

    Mix.Openmaize.copy_files(srcdir, files, mod_name)
    |> instructions()
  end

  def instructions([]) do
    """
    In the `web/router.ex` file, add the following line to the pipeline:

    plug Openmaize.Authenticate

    You will also need to configure Openmaize. See the documentation for
    Openmaize.Config for details.
    """
  end
  def instructions(errors) do
    files = Enum.join errors, "\n* "
    """
    The following files could not be installed:
    #{files}
    """
  end
end
