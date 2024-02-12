defmodule Telephony.Server do
  use GenServer
  alias Telephony.Core

  # Client API
  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  # Server API
  @impl true
  def init(subscribers), do: {:ok, subscribers}

  @impl true
  def handle_call({:create_subscriber, payload}, _from, subscribers) do
    case Core.create_subscriber(subscribers, payload) do
      {:error, _message} = err -> {:reply, err, subscribers}
      subscribers -> {:reply, subscribers, subscribers}
    end
  end
end
