ExUnit.start()

{:ok, _} = Application.ensure_all_started(:ecto)
{:ok, _} = Application.ensure_all_started(:postgrex)

Code.require_file "support/dummy_crypto.exs", __DIR__
Code.require_file "support/ecto_helper.exs", __DIR__
Code.require_file "support/ecto_db.exs", __DIR__
Code.require_file "support/setup_db.exs", __DIR__
Code.require_file "support/session_helper.exs", __DIR__
Code.require_file "support/access_control.exs", __DIR__

Openmaize.SetupDB.add_users()
