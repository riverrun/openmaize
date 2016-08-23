Code.require_file "../../support/mix_helper.exs", __DIR__

defmodule Mix.Tasks.Openmaize.Gen.EctodbTest do
  use ExUnit.Case
  import MixHelper

  @user_model Path.join(__DIR__, "../../support/dummy_user.ex")

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates openmaize_ecto files" do
    in_tmp "generates openmaize_ecto files", fn ->
      File.mkdir_p! "web/models"
      File.cp! @user_model, "web/models/user.ex"
      Mix.Tasks.Openmaize.Gen.Ectodb.run []

      assert_file "web/models/openmaize_ecto.ex"
      assert_file "test/models/openmaize_ecto_test.exs"

      assert_file "web/models/user.ex", fn file ->
        assert file =~ ":password, :string, virtual: true"
        assert file =~ "def auth_changeset(model, params, key) do"
        assert file =~ "OpenmaizeEcto.add_password_hash(params)"
      end
    end
  end

  test "generates openmaize_ecto files for confirmation" do
    in_tmp "generates openmaize_ecto files for confirmation", fn ->
      File.mkdir_p! "web/models"
      File.cp! @user_model, "web/models/user.ex"
      Mix.Tasks.Openmaize.Gen.Ectodb.run ["--confirm"]

      assert_file "web/models/openmaize_ecto.ex"
      assert_file "test/models/openmaize_ecto_test.exs"

      assert_file "web/models/user.ex", fn file ->
        assert file =~ "OpenmaizeEcto.add_confirm_token(key)"
        assert file =~ "def reset_changeset(model, params, key) do"
      end
    end
  end

  test "adds role to model" do
    in_tmp "adds role to model", fn ->
      File.mkdir_p! "web/models"
      File.cp! @user_model, "web/models/user.ex"
      Mix.Tasks.Openmaize.Gen.Ectodb.run ["--roles"]

      assert_file "web/models/user.ex", fn file ->
        IO.inspect file
        assert file =~ ":password, :string, virtual: true"
        assert file =~ "field :role, :string"
      end
    end
  end
end
