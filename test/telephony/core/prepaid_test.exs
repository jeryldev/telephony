defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Prepaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone: "1234567890",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{subscriber: subscriber}
  end

  describe "make_call/3" do
    test "with valid parameters", %{subscriber: subscriber} do
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
  end
end
