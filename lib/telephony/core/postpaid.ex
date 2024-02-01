defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.Call

  defstruct spent: 0

  defimpl SubscriberProtocol, for: __MODULE__ do
    @price_per_minute 1.04

    def print_invoice(_subscriber_type, calls, year, month) do
      Enum.reduce(calls, %{calls: [], value_spent: 0}, &filter_call(&1, &2, year, month))
    end

    def make_call(subscriber_type, time_spent, date) do
      subscriber_type
      |> update_spent(time_spent)
      |> add_call(time_spent, date)
    end

    def make_recharge(_subscriber_type, _value, _date) do
      {:error, "Only prepaid can make a recharge"}
    end

    def update_spent(subscriber_type, time_spent) do
      new_spent = @price_per_minute * time_spent
      %{subscriber_type | spent: subscriber_type.spent + new_spent}
    end

    def add_call(subscriber_type, time_spent, date) do
      call = Call.new(time_spent, date)
      {subscriber_type, call}
    end

    defp filter_call(%{date: date} = call, acc, year, month)
         when date.year == year and date.month == month do
      call_map =
        call
        |> Map.take([:time_spent, :date])
        |> Map.put(:value_spent, call.time_spent * @price_per_minute)

      %{calls: acc.calls ++ [call_map], value_spent: acc.value_spent + call_map.value_spent}
    end

    defp filter_call(_call, acc, _year, _month), do: acc
  end
end
