defmodule Mix.OpenmaizeTest do
  use ExUnit.Case

  test "base_name returns module name based on app name in config" do
    assert Openmaize.Utils.base_name == "Openmaize"
  end

end
