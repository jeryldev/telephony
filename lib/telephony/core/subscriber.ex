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

  def make_call(%{type: type} = subscriber, time_spent, date)
      when is_struct(type, Prepaid) or is_struct(type, Postpaid) do
    case SubscriberProtocol.make_call(type, time_spent, date) do
      {:error, message} -> {:error, message}
      {type, call} -> %{subscriber | type: type, calls: subscriber.calls ++ [call]}
    end
  end

  def make_call(_subscriber, _time_spent, _date), do: {:error, "Invalid subscriber"}

  def make_recharge(%{type: type} = subscriber, value, date)
      when is_struct(type, Prepaid) or is_struct(type, Postpaid) do
    case SubscriberProtocol.make_recharge(type, value, date) do
      {:error, message} -> {:error, message}
      type -> %{subscriber | type: type}
    end
  end

  def make_recharge(_subscriber, _value, _date), do: {:error, "Invalid subscriber"}

  def print_invoice(%{type: type} = subscriber, year, month)
      when is_struct(type, Prepaid) or is_struct(type, Postpaid) do
    invoice = SubscriberProtocol.print_invoice(type, subscriber.calls, year, month)
    %{subscriber: subscriber, invoice: invoice}
  end

  def print_invoice(_subscriber, _year, _month), do: {:error, "Invalid subscriber"}
end
