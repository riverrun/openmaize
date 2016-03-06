defmodule Openmaize.JWTmanager do
  use GenServer

  @thirty_mins 60_000
  #@thirty_mins 1_800_000
  #@sixty_mins 3_600_000

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Process.send_after(self, :clean, @thirty_mins)
    {:ok, %{jwtstore: create_subsets}}
  end

  def get_state(), do: GenServer.call(__MODULE__, :get_state)

  def query_jwt(jwt), do: GenServer.call(__MODULE__, {:query, jwt})

  def add_jwt(jwt), do: GenServer.cast(__MODULE__, {:push, jwt})

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:query, jwt}, _from, %{jwtstore: store} = state) do
    {:reply, Enum.any?(store, &MapSet.member?(&1, jwt)), state}
  end

  def handle_cast({:push, jwt}, %{jwtstore: [h|t]}) do
    {:noreply, %{jwtstore: [MapSet.put(h, jwt) | t]}}
  end

  def handle_info(:clean, %{jwtstore: store}) do
    store = update_store(store)
    Process.send_after(self, :clean, @thirty_mins)
    {:noreply, %{jwtstore: store}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def code_change(_old, state, _extra) do
    {:ok, state}
  end

  defp update_store(store) do
    [MapSet.new | List.delete_at(store, -1)]
  end

  defp create_subsets do
    num = div(Openmaize.Config.token_validity, 30) + 1
    for _ <- 1..num, do: MapSet.new
  end
end
