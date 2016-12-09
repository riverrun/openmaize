defmodule <%= base %>.SessionView do
  use <%= base %>.Web, :view<%= if html != false do %>

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end<% end %>
end
