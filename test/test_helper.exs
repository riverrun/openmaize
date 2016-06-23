ExUnit.start()

{:ok, _} = Application.ensure_all_started(:ecto)
{:ok, _} = Application.ensure_all_started(:postgrex)
{:ok, _} = Application.ensure_all_started(:openmaize_jwt)

Code.require_file "support/dummy_crypto.exs", __DIR__
Code.require_file "support/ecto_helper.exs", __DIR__
Code.require_file "support/ecto_db.exs", __DIR__
Code.require_file "support/setup_db.exs", __DIR__
Code.require_file "support/access_control.exs", __DIR__

Application.put_env(:openmaize, :db_module, Openmaize.EctoDB)

Openmaize.SetupDB.add_users()
