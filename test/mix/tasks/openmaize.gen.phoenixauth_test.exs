Code.require_file "../../support/mix_helper.exs", __DIR__

defmodule Mix.Tasks.Openmaize.Gen.PhoenixauthTest do
  use ExUnit.Case
  import MixHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates default html resource" do
    in_tmp "generates default html resource", fn ->
      send self(), {:mix_shell_input, :yes?, false}
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run []

      assert_file "web/controllers/authorize.ex"
      assert_file "test/controllers/authorize_test.exs"
      assert_file "web/models/openmaize_ecto.ex"
      refute_file "web/controllers/confirm.ex"
      refute_file "test/controllers/confirm_test.exs"

      assert_file "web/controllers/page_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:login_user]"
      end

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "def action(conn, _), do: auth_action conn, __MODULE__"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ "defmodule Openmaize.Router"
        assert file =~ "plug Openmaize.Authenticate"
        assert file =~ ~s(delete "/logout", PageController, :logout, as: :logout)
        assert file =~ ~s(resources "/users", UserController)
      end

      assert_received {:mix_shell, :info, ["\nPlease check the generated" <> _ = message]}
      assert message =~ ~s(See the documentation for Openmaize.Config)
    end
  end

  test "generates default api resource" do
    in_tmp "generates default api resource", fn ->
      send self(), {:mix_shell_input, :yes?, false}
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run ["--api"]

      assert_file "web/controllers/authorize.ex"
      assert_file "test/controllers/authorize_test.exs"
      assert_file "web/models/openmaize_ecto.ex"
      refute_file "web/controllers/confirm.ex"
      refute_file "test/controllers/confirm_test.exs"

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:login]"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ "defmodule Openmaize.Router"
        assert file =~ "plug OpenmaizeJWT.Authenticate"
        assert file =~ "pipe_through :api"
        assert file =~ ~s(post "/login", UserController, :login)
      end
    end
  end

  test "can generate resource without ecto" do
    in_tmp "can generate resource without ecto", fn ->
      send self(), {:mix_shell_input, :yes?, false}
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run ["--no-ecto"]

      assert_file "web/controllers/authorize.ex"
      refute_file "web/models/openmaize_ecto.ex"
    end
  end

  test "generates confirm files" do
    in_tmp "generates confirm files", fn ->
      send self(), {:mix_shell_input, :yes?, true}
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run []

      assert_file "web/controllers/authorize.ex"
      assert_file "test/controllers/authorize_test.exs"
      assert_file "web/models/openmaize_ecto.ex"
      assert_file "web/controllers/confirm.ex"
      assert_file "test/controllers/confirm_test.exs"

      assert_file "web/controllers/page_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:login_user]"
      end

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "def action(conn, _), do: auth_action conn, __MODULE__"
      end

    end
  end

  test "generates modules with roles" do
    in_tmp "generates modules with roles", fn ->
      send self(), {:mix_shell_input, :yes?, false}
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run ["--roles"]

      assert_file "web/controllers/page_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:login_user]"
      end

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "def action(conn, _), do: auth_action_role conn, [\"admin\", \"user\"], __MODULE__"
      end

    end
  end

end
