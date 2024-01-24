defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Invoice, Prepaid, Recharge, Subscriber}

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

  describe "Prepaid Invoice print/4" do
    test "with valid params" do
      date = NaiveDateTime.utc_now()
      last_month = NaiveDateTime.add(date, -30, :day)
      two_months_ago = NaiveDateTime.add(last_month, -30, :day)

      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{
          credits: 213,
          recharges: [
            %Recharge{value: 100, date: date},
            %Recharge{value: 100, date: last_month},
            %Recharge{value: 100, date: two_months_ago}
          ]
        },
        calls: [
          %Call{time_spent: 10, date: date},
          %Call{time_spent: 20, date: last_month},
          %Call{time_spent: 30, date: two_months_ago}
        ]
      }

      subscriber_type = subscriber.subscriber_type
      calls = subscriber.calls
      year = last_month.year
      month = last_month.month

      expected = %{
        calls: [
          %{time_spent: 20, value_spent: 29, date: last_month}
        ],
        recharges: [
          %{credits: 100, date: last_month}
        ]
      }

      result = Invoice.print(subscriber_type, calls, year, month)

      assert expected == result
    end
  end
end
