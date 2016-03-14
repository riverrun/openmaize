defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

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
                        {"confirm_test.exs", "web/controllers/confirm_test.exs"}]
    end

    Mix.Openmaize.copy_files srcdir, files, mod_name
  end

end
