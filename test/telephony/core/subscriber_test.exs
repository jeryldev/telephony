defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid, Prepaid, Recharge, Subscriber}

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
      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }

      assert expected == result
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
      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 0}
      }

      assert expected == result
    end
  end

  describe "make_call/3" do
    setup do
      date = NaiveDateTime.utc_now()

      postpaid = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 0}
      }

      prepaid = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 7.0, recharges: []},
        calls: [%Call{time_spent: 2, date: date}]
      }

      %{date: date, postpaid: postpaid, prepaid: prepaid}
    end

    test "with valid postpaid params", %{postpaid: postpaid} do
      new_date = NaiveDateTime.utc_now()
      result = Subscriber.make_call(postpaid, 2, new_date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 2.08},
        calls: [%Call{time_spent: 2, date: new_date}]
      }

      assert expected == result
    end

    test "with valid prepaid params", %{date: date, prepaid: prepaid} do
      new_date = NaiveDateTime.utc_now()
      result = Subscriber.make_call(prepaid, 1, new_date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 5.55, recharges: []},
        calls: [
          %Call{time_spent: 2, date: date},
          %Call{time_spent: 1, date: new_date}
        ]
      }

      assert expected == result
    end
  end

  describe "make_recharge/3" do
    setup do
      date = NaiveDateTime.utc_now()

      postpaid = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 0}
      }

      prepaid = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{credits: 7.0, recharges: []},
        calls: [%Call{time_spent: 2, date: date}]
      }

      %{date: date, postpaid: postpaid, prepaid: prepaid}
    end

    test "with valid prepaid recharge params", %{date: date, prepaid: prepaid} do
      new_date = NaiveDateTime.utc_now()
      result = Subscriber.make_recharge(prepaid, 100, new_date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Prepaid{
          credits: 107.0,
          recharges: [%Recharge{value: 100, date: new_date}]
        },
        calls: [%Call{time_spent: 2, date: date}]
      }

      assert expected == result
    end

    test "with valid postpaid recharge params", %{postpaid: postpaid} do
      new_date = NaiveDateTime.utc_now()
      result = Subscriber.make_recharge(postpaid, 100, new_date)

      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        subscriber_type: %Postpaid{spent: 0},
        calls: []
      }

      assert expected == result
    end
  end
end
