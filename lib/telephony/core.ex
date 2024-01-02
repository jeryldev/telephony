defmodule Telephony.Core do
  alias Telephony.Core.Subscriber

  def create_subscriber(subscribers, payload) do
    subscribers ++ [Subscriber.new(payload)]
  end
end
