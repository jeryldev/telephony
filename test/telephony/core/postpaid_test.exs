defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid}

  setup do
    %{postpaid: %Postpaid{spent: 0}}
  end

  describe "make_call/3" do
    test "with valid params", %{postpaid: postpaid} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = Subscriber.make_call(postpaid, time_spent, date)
      expected = {%Postpaid{spent: 2.08}, %Call{time_spent: 2, date: date}}
      assert expected == result
    end
  end

  describe "make_recharge/3" do
    test "with params", %{postpaid: postpaid} do
      value = 100
      date = NaiveDateTime.utc_now()
      result = Subscriber.make_recharge(postpaid, value, date)
      expected = {:error, "Only prepaid can make a recharge"}
      assert expected == result
    end
  end

  describe "Postpaid Invoice print/4" do
    test "with valid params" do
      date = NaiveDateTime.utc_now()
      last_month = NaiveDateTime.add(date, -31, :day)
      two_months_ago = NaiveDateTime.add(last_month, -31, :day)
      price_per_minute = 1.04
      postpaid = %Postpaid{spent: 100 * price_per_minute}

      calls = [
        %Call{time_spent: 10, date: date},
        %Call{time_spent: 20, date: last_month},
        %Call{time_spent: 30, date: two_months_ago}
      ]

      expected = %{
        value_spent: 20 * price_per_minute,
        calls: [
          %{time_spent: 20, value_spent: 20 * price_per_minute, date: last_month}
        ]
      }

      result =
        Subscriber.print_invoice(postpaid, calls, last_month.year, last_month.month)

      assert expected == result
    end
  end
end
