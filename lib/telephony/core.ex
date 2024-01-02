defmodule Telephony.Core do
  alias Telephony.Core.Subscriber

  def create_subscriber(subscribers, payload) do
    [Subscriber.new(payload) | subscribers]
  end
end
