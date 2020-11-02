defmodule TnciServerWeb.PageController do
  use TnciServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def test_websocket(conn, _params) do
    render(conn, "testws.html")
  end
end
