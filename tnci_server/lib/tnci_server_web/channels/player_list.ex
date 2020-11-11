defmodule TnciServer.PlayerList do
  use Agent

  # _opts is not used, is given as [] by the Phoenix Application
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def upsert_player_position("game:" <> game_id, %{x: x, y: y, user: user}) do
    IO.puts("STATE: updating position for user #{user}, game #{game_id}")

    Agent.update(__MODULE__, fn games_map ->
      Map.update(games_map, game_id, %{}, fn game_data ->
        Map.update(game_data, user, %{}, &Map.merge(&1, %{x: x, y: y}))
      end)
    end)
  end

  def get_players("game:" <> game_id) do
    Agent.get(__MODULE__, &Map.get(&1, game_id, %{}))
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end
