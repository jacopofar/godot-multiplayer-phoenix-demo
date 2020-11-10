defmodule TnciServer.PlayerList do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> 0 end, opts)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end
