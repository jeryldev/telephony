defprotocol SubscriberProtocol do
  @fallback_to_any true

  def print_invoice(type, calls, year, month)
  def make_call(type, time_spent, date)
  def make_recharge(type, value, date)
end

defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct [:full_name, :phone, type: :prepaid, calls: []]

  def new(%{type: :prepaid} = payload) do
    payload = %{payload | type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{type: :postpaid} = payload) do
    payload = %{payload | type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(subscriber, time_spent, date) do
    case SubscriberProtocol.make_call(subscriber.type, time_spent, date) do
      {:error, message} -> {:error, message}
      {type, call} -> %{subscriber | type: type, calls: subscriber.calls ++ [call]}
    end
  end

  def make_recharge(subscriber, value, date) do
    case SubscriberProtocol.make_recharge(subscriber.type, value, date) do
      {:error, message} -> {:error, message}
      type -> %{subscriber | type: type}
    end
  end
end
