defmodule X3m.Rabbit.Consumers do
  use Supervisor
  alias X3m.Rabbit

  def start_link(channel_manager, configuration, opts),
    do: Supervisor.start_link(__MODULE__, {channel_manager, configuration}, opts)

  def init({channel_manager, configuration}) do
    children =
      configuration
      |> Enum.map(&_define_worker(channel_manager, &1))

    supervise(children, strategy: :one_for_one)
  end

  defp _define_worker(channel_manager, {:publisher, name, targets}) do
    worker(Rabbit.Publisher, [channel_manager, name, targets, [name: name]], id: name)
  end

  defp _define_worker(channel_manager, {:listener, name, definition}) do
    worker(Rabbit.Listener, [channel_manager, name, definition, [name: name]], id: name)
  end
end
