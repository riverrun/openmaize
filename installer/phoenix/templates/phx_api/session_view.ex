defmodule <%= base %>.SessionView do
  use <%= base %>.Web, :view

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end
end
