defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.{Postpaid, Prepaid, Subscriber}

  describe "new/1" do
    test "with valid prepaid payload" do
      # Given
      payload = %{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: :prepaid
      }

      # When
      result = Subscriber.new(payload)

      # Then
      expect = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }

      assert expect == result
    end

    test "with valid postpaid payload" do
      # Given
      payload = %{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: :postpaid
      }

      # When
      result = Subscriber.new(payload)

      # Then
      expect = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 0}
      }

      assert expect == result
    end
  end
end
