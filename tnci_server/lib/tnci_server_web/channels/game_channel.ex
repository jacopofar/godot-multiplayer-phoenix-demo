defmodule TnciServerWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, _params, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("The player #{this_user} joined the game #{game_id}")
    {:ok, socket}
  end

  def handle_in("new_position", %{"x" => x, "y" => y}, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("new position for #{this_user}: (#{x}, #{y})")
    {:noreply, socket}
  end

  def handle_in("new_player", %{"x" => x, "y" => y}, socket) do
    this_user = socket.assigns[:user_name]
    IO.puts("Player #{this_user} spawned at: (#{x}, #{y})")
    broadcast!(socket, "new_player", %{user: this_user, x: x, y: y})
    {:noreply, socket}
  end
end
