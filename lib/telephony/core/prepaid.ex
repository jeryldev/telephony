defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Recharge}

  defstruct credits: 0, recharges: []

  defimpl SubscriberProtocol, for: __MODULE__ do
    @price_per_minute 1.45

    def print_invoice(
          %{recharges: recharges, credits: credits} = _prepaid_type,
          calls,
          year,
          month
        ) do
      recharges = Enum.reduce(recharges, [], &filter_recharge(&1, &2, year, month))
      calls = Enum.reduce(calls, [], &filter_call(&1, &2, year, month))
      %{recharges: recharges, calls: calls, credits: credits}
    end

    def make_call(type, time_spent, date) do
      if subscriber_has_credits(type, time_spent) do
        type
        |> update_credits_spent(time_spent)
        |> add_new_call(time_spent, date)
      else
        {:error, "Subscriber does not have credits"}
      end
    end

    def make_recharge(type, value, date) do
      recharge = Recharge.new(value, date)

      %{
        type
        | credits: type.credits + value,
          recharges: type.recharges ++ [recharge]
      }
    end

    defp subscriber_has_credits(type, time_spent) do
      type.credits >= @price_per_minute * time_spent
    end

    defp update_credits_spent(type, time_spent) do
      credits_spent = time_spent * @price_per_minute
      %{type | credits: type.credits - credits_spent}
    end

    defp add_new_call(type, time_spent, date) do
      call = Call.new(time_spent, date)
      {type, call}
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
