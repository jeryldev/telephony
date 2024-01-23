defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct [:full_name, :phone, subscriber_type: :prepaid, calls: []]

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_call(%{subscriber_type: subscriber_type} = subscriber, time_spent, date) do
    case subscriber_type do
      %Prepaid{} -> Prepaid.make_call(subscriber, time_spent, date)
      %Postpaid{} -> Postpaid.make_call(subscriber, time_spent, date)
    end
  end
end
