defmodule Telephony.Core do
  alias Telephony.Core.Subscriber

  @types ~w(prepaid postpaid)a

  def create_subscriber(subscribers, %{type: type} = payload)
      when type in @types do
    case Enum.find(subscribers, &(&1.phone == payload.phone)) do
      nil -> subscribers ++ [Subscriber.new(payload)]
      _ -> {:error, "Subscriber `#{payload.phone}`, already exists"}
    end
  end

  def create_subscriber(_subscribers, _payload) do
    {:error, "Only 'prepaid' and 'postpaid' are accepted"}
  end
end
