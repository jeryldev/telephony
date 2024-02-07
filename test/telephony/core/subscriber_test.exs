defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid, Prepaid, Recharge, Subscriber}

  describe "new/1" do
    test "with valid prepaid payload" do
      # Given
      payload = %{
        full_name: "John Doe",
        phone: "1234567890",
        type: :prepaid
      }

      # When
      result = Subscriber.new(payload)

      # Then
      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Prepaid{credits: 0, recharges: []}
      }

      assert expected == result
    end

    test "with valid postpaid payload" do
      # Given
      payload = %{
        full_name: "John Doe",
        phone: "1234567890",
        type: :postpaid
      }

      # When
      result = Subscriber.new(payload)

      # Then
      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Postpaid{spent: 0}
      }

      assert expected == result
    end
  end

  describe "prepaid" do
    test "make_call/3" do
      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Prepaid{credits: 10, recharges: []}
      }

      date = ~D[2024-02-06]

      assert Subscriber.make_call(subscriber, 1, date) ==
               %Subscriber{
                 full_name: "John Doe",
                 phone: "1234567890",
                 type: %Prepaid{credits: 8.55, recharges: []},
                 calls: [%Call{time_spent: 1, date: date}]
               }
    end

    test "make_recharge/3" do
      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Prepaid{credits: 10, recharges: []}
      }

      date = Date.utc_today()

      assert Subscriber.make_recharge(subscriber, 100, date) ==
               %Subscriber{
                 full_name: "John Doe",
                 phone: "1234567890",
                 type: %Prepaid{credits: 110, recharges: [%Recharge{value: 100, date: date}]}
               }
    end

    test "print_invoice/3" do
      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Prepaid{credits: 10, recharges: [%Recharge{value: 100, date: ~D[2024-02-06]}]},
        calls: [%Call{time_spent: 1, date: ~D[2024-02-06]}]
      }

      assert Subscriber.print_invoice(subscriber, 2021, 1) ==
               %{
                 invoice: %{calls: [], credits: 10, recharges: []},
                 subscriber: %Telephony.Core.Subscriber{
                   full_name: "John Doe",
                   phone: "1234567890",
                   type: %Telephony.Core.Prepaid{
                     credits: 10,
                     recharges: [%Telephony.Core.Recharge{value: 100, date: ~D[2024-02-06]}]
                   },
                   calls: [%Telephony.Core.Call{time_spent: 1, date: ~D[2024-02-06]}]
                 }
               }
    end
  end

  describe "postpaid" do
    test "make_call/3" do
      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Postpaid{spent: 0}
      }

      date = Date.utc_today()

      assert Subscriber.make_call(subscriber, 1, date) ==
               %Subscriber{
                 full_name: "John Doe",
                 phone: "1234567890",
                 type: %Postpaid{spent: 1.04},
                 calls: [%Call{time_spent: 1, date: date}]
               }
    end

    test "make_recharge/3" do
      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Postpaid{spent: 0}
      }

      date = Date.utc_today()

      assert Subscriber.make_recharge(subscriber, 100, date) ==
               {:error, "Only prepaid can make a recharge"}
    end

    test "print_invoice/3" do
      subscriber = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Postpaid{spent: 10},
        calls: [%Call{time_spent: 1, date: ~D[2024-02-06]}]
      }

      assert Subscriber.print_invoice(subscriber, 2021, 1) ==
               %{
                 invoice: %{calls: [], value_spent: 0},
                 subscriber: %Telephony.Core.Subscriber{
                   full_name: "John Doe",
                   phone: "1234567890",
                   type: %Telephony.Core.Postpaid{spent: 10},
                   calls: [%Telephony.Core.Call{time_spent: 1, date: ~D[2024-02-06]}]
                 }
               }
    end

    test "make_call/3 with invalid subscriber" do
      date = Date.utc_today()
      assert Subscriber.make_call(%{}, 1, date) == {:error, "Invalid subscriber"}
    end

    test "make_recharge/3 with invalid subscriber" do
      date = Date.utc_today()
      assert Subscriber.make_recharge(%{}, 100, date) == {:error, "Invalid subscriber"}
    end

    test "print_invoice/3 with invalid subscriber" do
      assert Subscriber.print_invoice(%{}, 2021, 1) == {:error, "Invalid subscriber"}
    end
  end
end
