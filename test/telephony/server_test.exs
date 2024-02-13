defmodule Telephony.ServerTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Postpaid, Recharge}
  alias Telephony.Server

  setup do
    process_name = :test
    {:ok, server_pid} = Server.start_link(process_name)
    payload = %{full_name: "John Doe", phone: "123456789", type: :prepaid}
    %{server_pid: server_pid, process_name: process_name, payload: payload}
  end

  describe "start_link/1" do
    test "starts the server", %{server_pid: server_pid} do
      assert Process.alive?(server_pid)
      assert [] == :sys.get_state(server_pid)
    end
  end

  describe "create_subscriber/1" do
    test "with valid params", %{server_pid: server_pid, payload: payload} do
      assert [] == :sys.get_state(server_pid)

      expected = [
        %Telephony.Core.Subscriber{
          full_name: "John Doe",
          phone: "123456789",
          type: %Prepaid{credits: 0, recharges: []},
          calls: []
        }
      ]

      result = GenServer.call(server_pid, {:create_subscriber, payload})
      assert expected == result
      assert expected == :sys.get_state(server_pid)
    end

    test "with invalid params", %{server_pid: server_pid} do
      assert [] == :sys.get_state(server_pid)
      payload = %{full_name: "John Doe", phone: "123456789", type: :invalid}
      assert {:error, _} = GenServer.call(server_pid, {:create_subscriber, payload})
      assert [] == :sys.get_state(server_pid)
    end
  end

  describe "search_subscriber/1" do
    test "with valid phone", %{server_pid: server_pid, payload: payload} do
      assert [] == :sys.get_state(server_pid)
      assert [expected] = GenServer.call(server_pid, {:create_subscriber, payload})
      result = GenServer.call(server_pid, {:search_subscriber, "123456789"})
      assert expected == result
    end

    test "with invalid phone", %{server_pid: server_pid, payload: payload} do
      assert [] == :sys.get_state(server_pid)
      assert [_expected] = GenServer.call(server_pid, {:create_subscriber, payload})
      result = GenServer.call(server_pid, {:search_subscriber, "0987654321"})
      assert {:error, "Subscriber `0987654321`, not found"} = result
    end
  end

  describe "make_recharge/1 prepaid" do
    test "with valid phone", %{server_pid: server_pid, payload: payload} do
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = payload.phone
      value = 100
      date = Date.utc_today()
      old_state = :sys.get_state(server_pid)
      old_subscriber_state = hd(old_state)
      assert [] = old_subscriber_state.type.recharges
      assert :ok = GenServer.cast(server_pid, {:make_recharge, phone, value, date})
      new_state = :sys.get_state(server_pid)
      new_subscriber_state = hd(new_state)
      assert [recharge] = new_subscriber_state.type.recharges
      assert 100 == recharge.value
    end

    test "with invalid phone", %{server_pid: server_pid, payload: payload} do
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = "0987654321"
      value = 100
      date = Date.utc_today()
      old_state = :sys.get_state(server_pid)
      assert :ok = GenServer.cast(server_pid, {:make_recharge, phone, value, date})
      new_state = :sys.get_state(server_pid)
      assert old_state == new_state
    end
  end

  describe "make_recharge/1 postpaid" do
    test "with valid phone", %{server_pid: server_pid, payload: payload} do
      payload = Map.put(payload, :type, :postpaid)
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = payload.phone
      value = 100
      date = Date.utc_today()
      old_state = :sys.get_state(server_pid)
      old_subscriber_state = hd(old_state)
      assert 0 == old_subscriber_state.type.spent
      assert :ok = GenServer.cast(server_pid, {:make_recharge, phone, value, date})
      new_state = :sys.get_state(server_pid)
      new_subscriber_state = hd(new_state)
      # postpaid cannot have recharges
      assert old_subscriber_state == new_subscriber_state
    end

    test "with invalid phone", %{server_pid: server_pid, payload: payload} do
      payload = Map.put(payload, :type, :postpaid)
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = "0987654321"
      value = 100
      date = Date.utc_today()
      old_state = :sys.get_state(server_pid)
      assert :ok = GenServer.cast(server_pid, {:make_recharge, phone, value, date})
      new_state = :sys.get_state(server_pid)
      assert old_state == new_state
    end
  end

  describe "make_call/1 prepaid" do
    test "with valid phone without credits", %{server_pid: server_pid, payload: payload} do
      [subscriber] = GenServer.call(server_pid, {:create_subscriber, payload})
      phone = payload.phone
      time_spent = 100
      date = Date.utc_today()
      expected = {:error, "Subscriber does not have credits"}
      result = GenServer.call(server_pid, {:make_call, phone, time_spent, date})
      assert expected == result
      new_state = :sys.get_state(server_pid)
      assert subscriber in new_state
    end

    test "with valid phone and credits", %{server_pid: server_pid, payload: payload} do
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = payload.phone
      date = Date.utc_today()
      assert :ok = GenServer.cast(server_pid, {:make_recharge, phone, 100, date})
      time_spent = 20

      expected = %Telephony.Core.Subscriber{
        full_name: "John Doe",
        phone: "123456789",
        type: %Prepaid{
          credits: 71.0,
          recharges: [%Recharge{value: 100, date: date}]
        },
        calls: [%Call{time_spent: 20, date: date}]
      }

      result = GenServer.call(server_pid, {:make_call, phone, time_spent, date})
      assert expected == result
      new_state = :sys.get_state(server_pid)
      assert expected in new_state
    end

    test "with invalid phone", %{server_pid: server_pid, payload: payload} do
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = "0987654321"
      time_spent = 100
      date = Date.utc_today()
      expected = {:error, "Subscriber `0987654321`, not found"}
      result = GenServer.call(server_pid, {:make_call, phone, time_spent, date})
      assert expected == result
    end
  end

  describe "make_call/1 pospaid" do
    test "with valid phone", %{server_pid: server_pid, payload: payload} do
      payload = Map.put(payload, :type, :postpaid)
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = payload.phone
      date = Date.utc_today()
      time_spent = 100

      expected = %Telephony.Core.Subscriber{
        full_name: "John Doe",
        phone: "123456789",
        type: %Postpaid{spent: 104.0},
        calls: [%Call{time_spent: 100, date: date}]
      }

      result = GenServer.call(server_pid, {:make_call, phone, time_spent, date})
      assert expected == result
      new_state = :sys.get_state(server_pid)
      assert expected in new_state
    end

    test "with invalid phone", %{server_pid: server_pid, payload: payload} do
      payload = Map.put(payload, :type, :postpaid)
      GenServer.call(server_pid, {:create_subscriber, payload})
      phone = "0987654321"
      time_spent = 100
      date = Date.utc_today()
      expected = {:error, "Subscriber `0987654321`, not found"}
      result = GenServer.call(server_pid, {:make_call, phone, time_spent, date})
      assert expected == result
    end
  end
end
