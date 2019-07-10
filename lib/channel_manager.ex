defmodule X3m.Rabbit.ChannelManager do
  use GenServer
  alias AMQP.Channel
  alias X3m.Rabbit
  require Logger

  ### Client API

  @doc """
  Starts the RabbitMQ connection.
  """
  def start_link(connection_name, opts),
    do: GenServer.start_link(__MODULE__, connection_name, opts)

  def get_channel(server, consumer),
    do: GenServer.call(server, {:get_channel, consumer})

  ### Server Callbacks

  def init(connection_name) do
    conn = Rabbit.Connection.get_connection(connection_name)
    Process.link(conn.pid)
    {:ok, %{conn: conn, consumers: %{}}}
  end

  def handle_call({:get_channel, consumer}, _from, state) do
    {:ok, chan, state} = _register_consumer(consumer, state)

    {:reply, chan, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    Logger.info(fn -> "Closing channel due to consumer #{inspect(pid)} crash" end)
    {chan, consumers} = Map.pop(state.consumers, pid)
    :ok = Channel.close(chan)
    {:noreply, %{state | consumers: consumers}}
  end

  def handle_info(_msg, state),
    do: {:noreply, state}

  defp _register_consumer(consumer, state) when is_atom(consumer) do
    consumer
    |> Process.whereis()
    |> _register_consumer(state)
  end

  defp _register_consumer(consumer, state) when is_pid(consumer) do
    {:ok, chan} = Channel.open(state.conn)
    consumers = Map.put(state.consumers, consumer, chan)
    Process.monitor(consumer)

    Logger.debug(fn ->
      "Registered consumer #{inspect(consumer)} with channel #{inspect(chan)}"
    end)

    {:ok, chan, %{state | consumers: consumers}}
  end
end
