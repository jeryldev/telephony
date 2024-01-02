defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.Subscriber

  describe "new/1" do
    test "with valid payload" do
      # Given
      payload = %{
        full_name: "John Doe",
        id: "1234567890",
        phone: "1234567890"
      }

      # When
      result = Subscriber.new(payload)

      # Then
      expect = %Subscriber{
        full_name: "John Doe",
        id: "1234567890",
        phone: "1234567890",
        subscriber_type: :prepaid
      }

      assert expect == result
    end
  end
end
