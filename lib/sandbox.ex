defmodule X3m.Rabbit.Sandbox do
  use Supervisor

  @moduledoc false

  def start_link(_, _, _),
    do: Supervisor.start_link(__MODULE__, :ok)

  def init(:ok),
    do: supervise([], strategy: :one_for_one)
end
