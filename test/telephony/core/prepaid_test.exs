defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Prepaid, Recharge, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    subscriber_without_credits = %Subscriber{
      full_name: "John Doe",
      phone: "1234567890",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: subscriber, subscriber_without_credits: subscriber_without_credits}
  end

  describe "make_call/3" do
    test "with valid params", %{subscriber: subscriber} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = Prepaid.make_call(subscriber, time_spent, date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 7.1, recharges: []},
        calls: [%Call{time_spent: 2, date: date}]
      }

      assert expected == result
    end

    test "error without credits", %{subscriber_without_credits: subscriber} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = Prepaid.make_call(subscriber, time_spent, date)
      expected = {:error, "Subscriber does not have credits"}
      assert expected == result
    end
  end

  describe "make_recharge/3" do
    test "with valid params", %{subscriber: subscriber} do
      value = 100
      date = NaiveDateTime.utc_now()
      result = Prepaid.make_recharge(subscriber, value, date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 110, recharges: [%Recharge{value: 100, date: date}]},
        calls: []
      }

      assert expected == result
    end
  end
end
