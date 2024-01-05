defmodule Telephony.Core.Prepaid do
  alias Telephony.Core.Call

  defstruct credits: 0, recharges: []

  @price_per_minute 1.45

  def make_call(%{subscriber_type: subscriber_type} = subscriber, time_spent, date) do
    credits_spent = time_spent * @price_per_minute
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credits_spent}
    call = Call.new(time_spent, date)

    %{
      subscriber
      | subscriber_type: subscriber_type,
        calls: subscriber.calls ++ [call]
    }
  end
end
