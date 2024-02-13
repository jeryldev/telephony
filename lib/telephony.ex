defmodule Telephony do
  @moduledoc """
  Documentation for `Telephony`.
  """
  @server :telephony_server

  @doc """
  Create subscriber.

  ## Examples

      iex> Telephony.create_subscriber(%{full_name: "John Doe", phone: "123456789", type: :prepaid})
  """
  def create_subscriber(payload) do
    GenServer.call(@server, {:create_subscriber, payload})
  end

  @doc """
  Search subscriber.

  ## Examples

      iex> Telephony.search_subscriber("123456789")
  """
  def search_subscriber(phone) do
    GenServer.call(@server, {:search_subscriber, phone})
  end

  @doc """
  Make recharge.

  ## Examples

      iex> Telephony.make_recharge("123456789", 100, ~D[2020-01-01])
  """
  def make_recharge(phone, value, date) do
    GenServer.cast(@server, {:make_recharge, phone, value, date})
  end

  @doc """
  Make call.

  ## Examples

      iex> Telephony.make_call("123456789", 10, ~D[2020-01-01])
  """
  def make_call(phone, duration, date) do
    GenServer.call(@server, {:make_call, phone, duration, date})
  end

  @doc """
  Print invoice.

  ## Examples

      iex> Telephony.print_invoice("123456789", 2020, 1)
  """
  def print_invoice(phone, year, month) do
    GenServer.call(@server, {:print_invoice, phone, year, month})
  end

  @doc """
  Print invoices.

  ## Examples

      iex> Telephony.print_invoices(2020, 1)
  """
  def print_invoices(year, month) do
    GenServer.call(@server, {:print_invoices, year, month})
  end
end
