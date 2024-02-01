defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Prepaid, Recharge}

  setup do
    prepaid = %Prepaid{credits: 10, recharges: []}
    prepaid_without_credits = %Prepaid{credits: 0, recharges: []}

    %{prepaid: prepaid, prepaid_without_credits: prepaid_without_credits}
  end

  describe "make_call/3" do
    test "with valid params", %{prepaid: prepaid} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = SubscriberProtocol.make_call(prepaid, time_spent, date)
      expected = {%Prepaid{credits: 7.1, recharges: []}, %Call{time_spent: 2, date: date}}
      assert expected == result
    end

    test "error without credits", %{prepaid_without_credits: prepaid_without_credits} do
      time_spent = 2
      date = NaiveDateTime.utc_now()
      result = SubscriberProtocol.make_call(prepaid_without_credits, time_spent, date)
      expected = {:error, "Subscriber does not have credits"}
      assert expected == result
    end
  end

  describe "make_recharge/3" do
    test "with valid params", %{prepaid: prepaid} do
      value = 100
      date = NaiveDateTime.utc_now()
      result = SubscriberProtocol.make_recharge(prepaid, value, date)
      expected = %Prepaid{credits: 110, recharges: [%Recharge{value: 100, date: date}]}
      assert expected == result
    end
  end

  describe "Prepaid Invoice print/4" do
    test "with valid params" do
      date = NaiveDateTime.utc_now()
      last_month = NaiveDateTime.add(date, -31, :day)
      two_months_ago = NaiveDateTime.add(last_month, -31, :day)

      subscriber = %Telephony.Core.Subscriber{
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

      expected = %{
        calls: [
          %{time_spent: 20, value_spent: 29, date: last_month}
        ],
        recharges: [
          %{credits: 100, date: last_month}
        ],
        credits: 213
      }

      subscriber_type = subscriber.subscriber_type
      calls = subscriber.calls
      year = last_month.year
      month = last_month.month

      result = SubscriberProtocol.print_invoice(subscriber_type, calls, year, month)

      assert expected == result
    end
  end
end
