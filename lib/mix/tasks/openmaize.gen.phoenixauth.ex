defmodule Mix.Tasks.Openmaize.Gen.Phoenixauth do
  use Mix.Task

  def run(args) do
    switches = [api: :boolean, confirm: :boolean]
    {opts, _argv, _} = OptionParser.parse(args, switches: switches)

    mod_name = Mix.Openmaize.base_name
    if opts[:api] do
      Mix.Openmaize.copy_files( # add test files
        [{"apiauth.ex", "web/controllers/authorize.ex"}],
        mod_name, !!opts[:confirm])
    else
      Mix.Openmaize.copy_files(
        [{"htmlauth.ex", "web/controllers/authorize.ex"}],
        mod_name, !!opts[:confirm])
    end
  end

end
