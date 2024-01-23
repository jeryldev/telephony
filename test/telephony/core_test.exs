defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.{Core, Core.Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "John Doe",
      phone: "1234567890",
      subscriber_type: :prepaid
    }

    {:ok, subscribers: subscribers, payload: payload}
  end

  describe "create_subscribers/2" do
    test "with valid params" do
      # Given
      subscribers = []

      payload =
        %{
          full_name: "John Doe",
          phone: "1234567890",
          subscriber_type: :prepaid
        }

      # When
      result = Core.create_subscriber(subscribers, payload)

      # Then
      expected = [
        %Subscriber{
          full_name: "John Doe",
          phone: "1234567890",
          subscriber_type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
        }
      ]

      assert expected == result
    end

    test "with valid params and existing subscribers", %{subscribers: subscribers} do
      # Given
      payload =
        %{
          full_name: "Jane Doe",
          phone: "0987654321",
          subscriber_type: :prepaid
        }

      # When
      result = Core.create_subscriber(subscribers, payload)

      # Then
      expected = [
        %Subscriber{
          full_name: "John Doe",
          phone: "1234567890",
          subscriber_type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
        },
        %Subscriber{
          full_name: "Jane Doe",
          phone: "0987654321",
          subscriber_type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
        }
      ]

      assert expected == result
    end

    test "show error with existing subscriber", %{subscribers: subscribers, payload: payload} do
      result = Core.create_subscriber(subscribers, payload)
      expected = {:error, "Subscriber `1234567890`, already exists"}
      assert expected == result
    end

    test "show error when susbcriber type does not exist", %{payload: payload} do
      payload = Map.put(payload, :subscriber_type, :something)
      result = Core.create_subscriber([], payload)
      assert {:error, "Only 'prepaid' and 'postpaid' are accepted"} == result
    end
  end
end
