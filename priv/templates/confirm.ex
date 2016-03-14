
  def handle_confirm(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def handle_confirm(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end

  def handle_reset(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    render(conn, <%= base %>.ErrorView, "error.json", %{error: message})
  end
  def handle_reset(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    render(conn, <%= base %>.UserView, "info.json", %{info: message})
  end
end
