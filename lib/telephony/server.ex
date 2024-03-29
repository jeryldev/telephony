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

  @impl true
  def handle_call({:search_subscriber, phone}, _from, subscribers) do
    case Core.search_subscriber(subscribers, phone) do
      {:error, _message} = err -> {:reply, err, subscribers}
      subscriber -> {:reply, subscriber, subscribers}
    end
  end

  @impl true
  def handle_call({:make_call, phone, duration, date}, _from, subscribers) do
    case Core.make_call(subscribers, phone, duration, date) do
      {subscribers, {:error, message}} -> {:reply, {:error, message}, subscribers}
      {subscribers, updated_subscriber} -> {:reply, updated_subscriber, subscribers}
    end
  end

  @impl true
  def handle_call({:print_invoice, phone, year, month}, _from, subscribers) do
    result = Core.print_invoice(subscribers, phone, year, month)
    {:reply, result, subscribers}
  end

  @impl true
  def handle_call({:print_invoices, year, month}, _from, subscribers) do
    result = Core.print_invoices(subscribers, year, month)
    {:reply, result, subscribers}
  end

  @impl true
  def handle_cast({:make_recharge, phone, value, date}, subscribers) do
    case Core.make_recharge(subscribers, phone, value, date) do
      {subscribers, {:error, _message}} -> {:noreply, subscribers}
      {subscribers, _updated_subscriber} -> {:noreply, subscribers}
    end
  end
end
