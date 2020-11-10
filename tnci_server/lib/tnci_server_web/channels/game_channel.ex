defmodule TnciServerWeb.GameChannel do
  use Phoenix.Channel
  intercept ["new_position"]

  def join("game:" <> game_id, _params, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("The player #{this_user} joined the game #{game_id}")
    {:ok, socket}
  end

  def handle_in("new_player", %{"x" => x, "y" => y}, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("Player #{this_user} spawned at: (#{x}, #{y})")
    # TODO here manage the player table
    Agent.update(:player_list, fn state ->
      state + 1
    end)

    # TODO here retrieve the players already there and send the list to the newcomer
    IO.puts(Agent.get(:player_list, & &1))
    broadcast!(socket, "new_player", %{user: this_user, x: x, y: y})
    {:noreply, socket}
  end

  def handle_in("new_position", %{"x" => x, "y" => y}, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("new position for #{this_user}: (#{x}, #{y})")
    broadcast!(socket, "new_position", %{user: this_user, x: x, y: y})
    {:noreply, socket}
  end

  def handle_out("new_position", payload, socket) do
    IO.puts("new position for #{payload[:user]} target is #{socket.assigns[:user_name]}")

    if socket.assigns[:user_name] !== payload[:user] do
      push(socket, "new_position", payload)
    end

    {:noreply, socket}
  end
end
