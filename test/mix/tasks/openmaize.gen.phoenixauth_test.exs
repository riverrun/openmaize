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
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run []

      assert_file "web/controllers/authorize.ex"
      assert_file "web/templates/session/new.html.eex"

      assert_file "web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:create]"
        refute file =~ "def confirm_email(%Plug.Conn{private: %{openmaize_error: message}}"
      end

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "plug :user_check when action in [:index, :show]"
        assert file =~ "plug :id_check when action in [:edit, :update, :delete]"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ "defmodule Openmaize.Router"
        assert file =~ "plug Openmaize.Authenticate"
        assert file =~ ~s(resources "/sessions", SessionController)
        assert file =~ ~s(resources "/users", UserController)
      end

      assert_received {:mix_shell, :info, ["\nPlease check the generated" <> _ = message]}
      assert message =~ ~s(See the documentation for Openmaize.Config)
    end
  end

  test "generates confirm functionality" do
    in_tmp "generates confirm functionality", fn ->
      Mix.Tasks.Openmaize.Gen.Phoenixauth.run ["--confirm"]

      assert_file "lib/openmaize/mailer.ex"
      assert_file "web/controllers/authorize.ex"

      assert_file "web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Openmaize.Login when action in [:create]"
        assert file =~ "def confirm_email(%Plug.Conn{private: %{openmaize_error: message}}"
      end

      assert_file "web/controllers/user_controller.ex", fn file ->
        assert file =~ "plug :user_check when action in [:index, :show]"
        assert file =~ "plug :id_check when action in [:edit, :update, :delete]"
      end

      assert_file "web/router.ex", fn file ->
        assert file =~ ~s(resources "/sessions", SessionController)
        assert file =~ ~s(get "/sessions/confirm_email", SessionController)
        assert file =~ ~s(resources "/password_resets", PasswordResetController)
      end
    end
  end

end
