defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.{Core, Core.Subscriber}

  describe "create_subscribers/2" do
    test "with valid params" do
      # Given
      subscribers = []

      payload =
        %{
          full_name: "John Doe",
          id: "1234567890",
          phone: "1234567890"
        }

      # When
      result = Core.create_subscriber(subscribers, payload)

      # Then
      expect = [
        %Subscriber{
          full_name: "John Doe",
          id: "1234567890",
          phone: "1234567890",
          subscriber_type: :prepaid
        }
      ]

      assert expect == result
    end
  end
end
