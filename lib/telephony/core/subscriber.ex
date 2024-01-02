defmodule Telephony.Core.Subscriber do
  defstruct [:full_name, :phone, subscriber_type: :prepaid]

  def new(payload) do
    struct(__MODULE__, payload)
  end
end
