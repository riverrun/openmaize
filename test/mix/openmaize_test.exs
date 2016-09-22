defmodule Mix.OpenmaizeTest do
  use ExUnit.Case

  test "base_module returns module name based on app name in config" do
    assert Openmaize.Utils.base_module == "Openmaize"
  end

end
