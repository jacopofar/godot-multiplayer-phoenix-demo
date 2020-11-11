defmodule TnciServerWeb.GameChannel do
  use Phoenix.Channel
  alias TnciServer.PlayerList, as: PlayerList

  intercept ["new_position"]

  def join("game:" <> game_id, _params, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("The player #{this_user} joined the game #{game_id}")
    {:ok, socket}
  end

  def handle_in("new_player", %{"x" => x, "y" => y}, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("Player #{this_user} spawned at: (#{x}, #{y})")

    for {player, player_data} <- PlayerList.get_players(socket.topic) do
      IO.inspect({"player:", player, "data:", player_data, "x coordinate", player_data[:x]})
      push(socket, "new_player", %{user: player, x: player_data[:x], y: player_data[:y]})
    end

    PlayerList.upsert_player_position(socket.topic, %{x: x, y: y, user: this_user})

    broadcast!(socket, "new_player", %{user: this_user, x: x, y: y})
    {:noreply, socket}
  end

  def handle_in("new_position", %{"x" => x, "y" => y}, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("new position for #{this_user}: (#{x}, #{y})")
    PlayerList.upsert_player_position(socket.topic, %{x: x, y: y, user: this_user})
    broadcast!(socket, "new_position", %{user: this_user, x: x, y: y})
    {:noreply, socket}
  end

  def handle_out("new_position", payload, socket) do
    # IO.puts("new position for #{payload[:user]} target is #{socket.assigns[:user_name]}")

    if socket.assigns[:user_name] !== payload[:user] do
      push(socket, "new_position", payload)
    end

    {:noreply, socket}
  end
end
