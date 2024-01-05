defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct [:full_name, :phone, subscriber_type: :prepaid]

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end
end
