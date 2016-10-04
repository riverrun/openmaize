Code.require_file "../../support/mix_helper.exs", __DIR__

defmodule Mix.Tasks.Openmaize.Gen.EctodbTest do
  use ExUnit.Case
  import MixHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates openmaize_ecto files" do
    in_tmp "generates openmaize_ecto files", fn ->
      Mix.Tasks.Openmaize.Gen.Ectodb.run []
      assert_file "web/models/openmaize_ecto.ex"
      assert_file "test/models/openmaize_ecto_test.exs"
    end
  end

end
