defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "John Doe",
      phone: "1234567890",
      subscriber_type: %Postpaid{spent: 0},
      calls: []
    }

    %{subscriber: subscriber}
  end

  describe "make_call/3" do
    test "with valid params", %{subscriber: subscriber} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = Postpaid.make_call(subscriber, time_spent, date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 2.08},
        calls: [%Call{time_spent: 2, date: date}]
      }

      assert expected == result
    end
  end
end
