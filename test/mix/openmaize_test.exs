defmodule Mix.OpenmaizeTest do
  use ExUnit.Case

  test "base_name returns module name based on app name in config" do
    assert Mix.Openmaize.base_name == "Openmaize"
  end

end
