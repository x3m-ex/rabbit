defmodule X3m.Rabbit.Connection do
  use GenServer
  use AMQP
  require Logger

  ### Client API

  @doc """
  Starts the RabbitMQ connection.
  """
  def start_link(bus_settings, opts),
    do: GenServer.start_link(__MODULE__, bus_settings, opts)

  def get_connection(server),
    do: GenServer.call(server, :get_connection)

  ### Server Callbacks

  def init(bus_settings) do
    max_attempts = bus_settings[:max_attempts] || :infinity
    wait_before_retry = bus_settings[:wait_before_retry] || 1_000
    _connect_to_rabbit(bus_settings, 1, max_attempts, wait_before_retry)
  end

  def handle_call(:get_connection, _from, conn),
    do: {:reply, conn, conn}

  defp _connect_to_rabbit(_bus_settings, attempt, attempt, _), do: {:error, :cannot_connect}

  defp _connect_to_rabbit(bus_settings, attempt, max_attempts, wait_before_retry) do
    Logger.info(fn -> "Connecting to RabbitMQ... (#{attempt}. attempt)" end)
    Logger.debug(fn -> inspect(bus_settings) end)

    case Connection.open(bus_settings) do
      {:ok, conn} ->
        Process.link(conn.pid)
        {:ok, conn}

      _e ->
        Logger.warn(fn ->
          "Connection unsuccessful. Will have #{attempt + 1}. retry in a second"
        end)

        :timer.sleep(wait_before_retry)
        _connect_to_rabbit(bus_settings, attempt + 1, max_attempts, wait_before_retry)
    end
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    Logger.info(fn -> "Successfully registered consumer with tag: #{consumer_tag}" end)
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan) do
    Logger.error(fn -> "Consumer has been unexpectedly cancelled with tag: #{consumer_tag}" end)
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan) do
    Logger.info(fn -> "Basic cancel successfull: #{consumer_tag}" end)
    {:noreply, chan}
  end
end
