defmodule Subscriber.Subscriber do
  defstruct [:full_name, :id, :phone, subscriber_type: :prepaid]

  def new(payload) do
    struct(__MODULE__, payload)
  end
end
