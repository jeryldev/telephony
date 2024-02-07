defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.{Core, Core.Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Core.Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "John Doe",
      phone: "1234567890",
      type: :prepaid
    }

    {:ok, subscribers: subscribers, payload: payload}
  end

  describe "create_subscribers/2" do
    test "with valid params" do
      # Given
      subscribers = []

      payload =
        %{
          full_name: "John Doe",
          phone: "1234567890",
          type: :prepaid
        }

      # When
      result = Core.create_subscriber(subscribers, payload)

      # Then
      expected = [
        %Subscriber{
          full_name: "John Doe",
          phone: "1234567890",
          type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
        }
      ]

      assert expected == result
    end

    test "with valid params and existing subscribers", %{subscribers: subscribers} do
      # Given
      payload =
        %{
          full_name: "Jane Doe",
          phone: "0987654321",
          type: :prepaid
        }

      # When
      result = Core.create_subscriber(subscribers, payload)

      # Then
      expected = [
        %Subscriber{
          full_name: "John Doe",
          phone: "1234567890",
          type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
        },
        %Subscriber{
          full_name: "Jane Doe",
          phone: "0987654321",
          type: %Telephony.Core.Prepaid{credits: 0, recharges: []}
        }
      ]

      assert expected == result
    end

    test "show error with existing subscriber", %{subscribers: subscribers, payload: payload} do
      result = Core.create_subscriber(subscribers, payload)
      expected = {:error, "Subscriber `1234567890`, already exists"}
      assert expected == result
    end

    test "show error when susbcriber type does not exist", %{payload: payload} do
      payload = Map.put(payload, :type, :something)
      result = Core.create_subscriber([], payload)
      assert {:error, "Only 'prepaid' and 'postpaid' are accepted"} == result
    end
  end

  describe "search_subscriber/2" do
    test "with valid subscriber to search", %{subscribers: subscribers} do
      expected = %Subscriber{
        full_name: "John Doe",
        phone: "1234567890",
        type: %Core.Prepaid{credits: 0, recharges: []}
      }

      result = Core.search_subscriber(subscribers, "1234567890")

      assert expected == result
    end

    test "with invalid subscriber to search", %{subscribers: subscribers} do
      expected = {:error, "Subscriber `0987654321`, not found"}
      result = Core.search_subscriber(subscribers, "0987654321")
      assert expected == result
    end
  end

  describe "make_recharge/4 for prepaid" do
    setup do
      subscribers = [
        %Subscriber{
          full_name: "John Doe",
          phone: "1234567890",
          type: %Core.Prepaid{credits: 0, recharges: []}
        }
      ]

      {:ok, subscribers: subscribers}
    end

    test "with valid params", %{subscribers: subscribers} do
      date = NaiveDateTime.utc_now()

      expected =
        {[
           %Subscriber{
             full_name: "John Doe",
             phone: "1234567890",
             type: %Core.Prepaid{
               credits: 100,
               recharges: [%Core.Recharge{value: 100, date: date}]
             }
           }
         ],
         %Subscriber{
           full_name: "John Doe",
           phone: "1234567890",
           type: %Core.Prepaid{credits: 100, recharges: [%Core.Recharge{value: 100, date: date}]}
         }}

      result = Core.make_recharge(subscribers, "1234567890", 100, date)

      assert expected == result
    end

    test "with invalid subscriber to make recharge", %{subscribers: subscribers} do
      expected = {subscribers, {:error, "Subscriber `0987654321`, not found"}}
      result = Core.make_recharge(subscribers, "0987654321", 100, NaiveDateTime.utc_now())
      assert expected == result
    end
  end

  describe "make_recharge/4 for postpaid" do
    setup do
      subscribers = [
        %Subscriber{
          full_name: "John Doe",
          phone: "1234567890",
          type: %Core.Postpaid{spent: 0}
        }
      ]

      {:ok, subscribers: subscribers}
    end

    test "with valid params", %{subscribers: subscribers} do
      date = NaiveDateTime.utc_now()

      expected =
        {[
           %Subscriber{
             full_name: "John Doe",
             phone: "1234567890",
             type: %Core.Postpaid{spent: 0}
           }
         ], {:error, "Only prepaid can make a recharge"}}

      result = Core.make_recharge(subscribers, "1234567890", 100, date)

      assert expected == result
    end

    test "with invalid subscriber to make recharge", %{subscribers: subscribers} do
      expected = {subscribers, {:error, "Subscriber `0987654321`, not found"}}
      result = Core.make_recharge(subscribers, "0987654321", 100, NaiveDateTime.utc_now())
      assert expected == result
    end
  end
end
