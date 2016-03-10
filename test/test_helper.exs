ExUnit.start()

Code.require_file "support/ecto_helper.exs", __DIR__
Code.require_file "support/setup_db.exs", __DIR__

Openmaize.SetupDB.add_users()

Application.put_env(:openmaize, :repo, Openmaize.TestRepo)
Application.put_env(:openmaize, :user_model, Openmaize.User)
