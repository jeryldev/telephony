defmodule Telephony.Core do
  alias Telephony.Core.Subscriber

  @types ~w(prepaid postpaid)a

  def create_subscriber(subscribers, %{type: type} = payload)
      when type in @types do
    case Enum.find(subscribers, &(&1.phone == payload.phone)) do
      nil -> subscribers ++ [Subscriber.new(payload)]
      _ -> {:error, "Subscriber `#{payload.phone}`, already exists"}
    end
  end

  def create_subscriber(_subscribers, _payload) do
    {:error, "Only 'prepaid' and 'postpaid' are accepted"}
  end

  def search_subscriber(subscribers, phone) do
    case Enum.find(subscribers, &(&1.phone == phone)) do
      nil -> {:error, "Subscriber `#{phone}`, not found"}
      subscriber -> subscriber
    end
  end

  def make_recharge(subscribers, phone, value, date) do
    subscribers
    |> search_subscriber(phone)
    |> maybe_recharge_subscriber(subscribers, value, date)
  end

  defp maybe_recharge_subscriber({:error, _message} = err, subscribers, _value, _date) do
    {subscribers, err}
  end

  defp maybe_recharge_subscriber(subscriber, subscribers, value, date) do
    case Subscriber.make_recharge(subscriber, value, date) do
      {:error, message} ->
        {subscribers, {:error, message}}

      recharged_subscriber ->
        subscribers = List.delete(subscribers, subscriber)
        {subscribers ++ [recharged_subscriber], recharged_subscriber}
    end
  end
end
