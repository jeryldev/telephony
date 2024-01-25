defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Invoice, Postpaid, Subscriber}

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

  describe "Postpaid Invoice print/4" do
    test "with valid params" do
      date = NaiveDateTime.utc_now()
      last_month = NaiveDateTime.add(date, -30, :day)
      two_months_ago = NaiveDateTime.add(last_month, -30, :day)
      price_per_minute = 1.04

      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 100 * price_per_minute},
        calls: [
          %Call{time_spent: 10, date: date},
          %Call{time_spent: 20, date: last_month},
          %Call{time_spent: 30, date: two_months_ago}
        ]
      }

      expected = %{
        value_spent: 20 * price_per_minute,
        calls: [
          %{time_spent: 20, value_spent: 20 * price_per_minute, date: last_month}
        ]
      }

      subscriber_type = subscriber.subscriber_type
      calls = subscriber.calls
      year = last_month.year
      month = last_month.month

      result = Invoice.print(subscriber_type, calls, year, month)

      assert expected == result
    end
  end
end
