defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.{Call, Invoice, Recharge}

  defstruct credits: 0, recharges: []

  @price_per_minute 1.45

  def make_call(subscriber, time_spent, date) do
    if subscriber_has_credits(subscriber, time_spent) do
      subscriber
      |> update_credits_spent(time_spent)
      |> add_new_call(time_spent, date)
    else
      {:error, "Subscriber does not have credits"}
    end
  end

  def make_recharge(%{subscriber_type: subscriber_type} = subscriber, value, date) do
    recharge = Recharge.new(value, date)

    subscriber_type = %{
      subscriber_type
      | credits: subscriber_type.credits + value,
        recharges: subscriber_type.recharges ++ [recharge]
    }

    %{subscriber | subscriber_type: subscriber_type}
  end

  defimpl Invoice, for: __MODULE__ do
    @price_per_minute 1.45
    def print(%{recharges: recharges} = _subscriber_type, calls, year, month) do
      recharges =
        Enum.reduce(recharges, [], fn recharge, acc ->
          if recharge.date.year == year and recharge.date.month == month,
            do: acc ++ [%{credits: recharge.value, date: recharge.date}],
            else: acc
        end)

      calls =
        Enum.reduce(calls, [], fn call, acc ->
          if call.date.year == year and call.date.month == month do
            call_map =
              call
              |> Map.take([:time_spent, :date])
              |> Map.put(:value_spent, call.time_spent * @price_per_minute)

            acc ++ [call_map]
          else
            acc
          end
        end)

      %{recharges: recharges, calls: calls}
    end
  end

  defp subscriber_has_credits(subscriber, time_spent) do
    subscriber.subscriber_type.credits >= @price_per_minute * time_spent
  end

  defp update_credits_spent(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    credits_spent = time_spent * @price_per_minute
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credits_spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end
end
