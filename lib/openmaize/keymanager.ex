defmodule Openmaize.Keymanager do
  use GenServer

  alias Openmaize.Config

  @oneday 86_400_000

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: Keymanager)
  end

  def init([]) do
    Process.send_after(self, :rotate, Config.keyrotate_days * @oneday)
    {:ok, %{key_1: get_key, key_2: get_key, current_kid: "1"}}
  end

  def get_key("1"), do: GenServer.call(Keymanager, :get_key_1)
  def get_key("2"), do: GenServer.call(Keymanager, :get_key_2)

  def get_current_kid do
    GenServer.call(Keymanager, :get_current_kid)
  end

  def handle_call(:get_key_1, _from, %{key_1: key} = state) do
    {:reply, key, state}
  end
  def handle_call(:get_key_2, _from, %{key_2: key} = state) do
    {:reply, key, state}
  end
  def handle_call(:get_current_kid, _from, %{current_kid: kid} = state) do
    {:reply, kid, state}
  end

  def handle_info(:rotate, state) do
    state = update_state(state)
    Process.send_after(self, :rotate, Config.keyrotate_days * @oneday)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp update_state(%{current_kid: "1"} = state) do
    %{state | current_kid: "2", key_2: get_key}
  end
  defp update_state(%{current_kid: "2"} = state) do
    %{state | current_kid: "1", key_1: get_key}
  end

  defp get_key do
    :crypto.strong_rand_bytes(32) |> Base.encode64
  end

end
