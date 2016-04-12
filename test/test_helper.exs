ExUnit.start()

{:ok, _} = Application.ensure_all_started(:ecto)
{:ok, _} = Application.ensure_all_started(:postgrex)
{:ok, _} = Application.ensure_all_started(:openmaize_jwt)

Code.require_file "support/ecto_helper.exs", __DIR__
Code.require_file "support/setup_db.exs", __DIR__
Code.require_file "support/access_control.exs", __DIR__

Openmaize.SetupDB.add_users()

Application.put_env(:openmaize, :repo, Openmaize.TestRepo)
Application.put_env(:openmaize, :user_model, Openmaize.User)
