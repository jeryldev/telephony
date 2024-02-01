defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Recharge}

  defstruct credits: 0, recharges: []

  defimpl SubscriberProtocol, for: __MODULE__ do
    @price_per_minute 1.45

    def print_invoice(
          %{recharges: recharges, credits: credits} = _prepaid_subscriber_type,
          calls,
          year,
          month
        ) do
      recharges = Enum.reduce(recharges, [], &filter_recharge(&1, &2, year, month))
      calls = Enum.reduce(calls, [], &filter_call(&1, &2, year, month))
      %{recharges: recharges, calls: calls, credits: credits}
    end

    def make_call(subscriber_type, time_spent, date) do
      if subscriber_has_credits(subscriber_type, time_spent) do
        subscriber_type
        |> update_credits_spent(time_spent)
        |> add_new_call(time_spent, date)
      else
        {:error, "Subscriber does not have credits"}
      end
    end

    def make_recharge(subscriber_type, value, date) do
      recharge = Recharge.new(value, date)

      %{
        subscriber_type
        | credits: subscriber_type.credits + value,
          recharges: subscriber_type.recharges ++ [recharge]
      }
    end

    defp subscriber_has_credits(subscriber_type, time_spent) do
      subscriber_type.credits >= @price_per_minute * time_spent
    end

    defp update_credits_spent(subscriber_type, time_spent) do
      credits_spent = time_spent * @price_per_minute
      %{subscriber_type | credits: subscriber_type.credits - credits_spent}
    end

    defp add_new_call(subscriber_type, time_spent, date) do
      call = Call.new(time_spent, date)
      {subscriber_type, call}
    end

    defp filter_recharge(%{date: date} = recharge, acc, year, month)
         when date.year == year and date.month == month do
      acc ++ [%{credits: recharge.value, date: recharge.date}]
    end

    defp filter_recharge(_recharge, acc, _year, _month), do: acc

    defp filter_call(%{date: date} = call, acc, year, month)
         when date.year == year and date.month == month do
      call_map =
        call
        |> Map.take([:time_spent, :date])
        |> Map.put(:value_spent, call.time_spent * @price_per_minute)

      acc ++ [call_map]
    end

    defp filter_call(_call, acc, _year, _month), do: acc
  end
end
