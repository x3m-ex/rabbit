defmodule X3m.Rabbit.Supervisor do
  use Supervisor

  alias X3m.Rabbit

  @moduledoc false

  def start_link([prefix, bus_settings, configuration]),
    do: start_link(prefix, bus_settings, configuration)

  def start_link(prefix, bus_settings, configuration) do
    prefix = Module.concat(prefix, X3m.Rabbit)
    name = Module.concat(prefix, Supervisor)
    Supervisor.start_link(__MODULE__, {prefix, bus_settings, configuration}, name: name)
  end

  def init({prefix, bus_settings, configuration}) do
    connection_name = Module.concat(prefix, Connection)
    channel_manager = Module.concat(prefix, ChannelManager)
    consumers_name = Module.concat(prefix, Consumers)

    children = [
      worker(Rabbit.Connection, [bus_settings, [name: connection_name]]),
      worker(Rabbit.ChannelManager, [connection_name, [name: channel_manager]]),
      supervisor(Rabbit.Consumers, [channel_manager, configuration, [name: consumers_name]])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end
