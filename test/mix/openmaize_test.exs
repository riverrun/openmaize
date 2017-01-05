defmodule Mix.OpenmaizeTest do
  use ExUnit.Case

  test "base_name returns app name" do
    assert Mix.Openmaize.base_name == "openmaize"
  end

  test "base_module returns module name based on app name in config" do
    assert Mix.Openmaize.base_module == "Openmaize"
  end
end
