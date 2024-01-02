defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.{Core, Core.Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "John Doe",
        id: "1234567890",
        phone: "1234567890",
        subscriber_type: :prepaid
      }
    ]

    {:ok, subscribers: subscribers}
  end

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

    test "with valid params and existing subscribers", %{subscribers: subscribers} do
      # Given
      payload =
        %{
          full_name: "Jane Doe",
          id: "0987654321",
          phone: "0987654321"
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
        },
        %Subscriber{
          full_name: "Jane Doe",
          id: "0987654321",
          phone: "0987654321",
          subscriber_type: :prepaid
        }
      ]

      assert expect == result
    end
  end
end
