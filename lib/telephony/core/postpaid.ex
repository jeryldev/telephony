defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.{Call, Invoice}

  defstruct spent: 0

  @price_per_minute 1.04

  def make_call(subscriber, time_spent, date) do
    subscriber
    |> update_spent(time_spent)
    |> add_call(time_spent, date)
  end

  def update_spent(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    new_spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + new_spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  def add_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end

  defimpl Invoice, for: __MODULE__ do
    @price_per_minute 1.04

    def print(_postpaid_subscriber_type, calls, year, month) do
      Enum.reduce(calls, %{calls: [], value_spent: 0}, fn call, acc ->
        if call.date.year == year and call.date.month == month do
          call_map =
            call
            |> Map.take([:time_spent, :date])
            |> Map.put(:value_spent, call.time_spent * @price_per_minute)

          %{calls: acc.calls ++ [call_map], value_spent: acc.value_spent + call_map.value_spent}
        else
          acc
        end
      end)
    end
  end
end
