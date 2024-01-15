defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.Call

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
end
