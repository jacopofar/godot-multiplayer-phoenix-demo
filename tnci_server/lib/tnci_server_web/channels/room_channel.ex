defmodule TnciServerWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    IO.puts("Somebody joined the lobby!")
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    if body != "fnord" do
      broadcast!(socket, "new_msg", %{body: body})
    else
      push(socket, "new_msg", %{body: "****"})
    end
    {:noreply, socket}
  end
end
