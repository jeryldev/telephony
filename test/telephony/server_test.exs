defmodule Telephony.ServerTest do
  use ExUnit.Case
  alias Telephony.Server

  setup do
    process_name = :test
    {:ok, server_pid} = Server.start_link(process_name)
    %{server_pid: server_pid, process_name: process_name}
  end

  describe "start_link/1" do
    test "starts the server", %{server_pid: server_pid} do
      assert Process.alive?(server_pid)
      assert [] == :sys.get_state(server_pid)
    end
  end

  describe "create_subscriber/1" do
    test "with valid params", %{server_pid: server_pid} do
      assert [] == :sys.get_state(server_pid)
      payload = %{full_name: "John Doe", phone: "123456789", type: :prepaid}

      expected = [
        %Telephony.Core.Subscriber{
          full_name: "John Doe",
          phone: "123456789",
          type: %Telephony.Core.Prepaid{credits: 0, recharges: []},
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
    test "with valid phone", %{server_pid: server_pid} do
      assert [] == :sys.get_state(server_pid)
      payload = %{full_name: "John Doe", phone: "123456789", type: :prepaid}
      assert [expected] = GenServer.call(server_pid, {:create_subscriber, payload})
      result = GenServer.call(server_pid, {:search_subscriber, "123456789"})
      assert expected == result
    end

    test "with invalid phone", %{server_pid: server_pid} do
      assert [] == :sys.get_state(server_pid)
      payload = %{full_name: "John Doe", phone: "123456789", type: :prepaid}
      assert [_expected] = GenServer.call(server_pid, {:create_subscriber, payload})
      result = GenServer.call(server_pid, {:search_subscriber, "0987654321"})
      assert {:error, "Subscriber `0987654321`, not found"} = result
    end
  end

  describe "make_recharge/1" do
    test "with valid phone", %{server_pid: server_pid} do
      payload = %{full_name: "John Doe", phone: "123456789", type: :prepaid}
      GenServer.call(server_pid, {:create_subscriber, payload})
      date = Date.utc_today()
      old_state = :sys.get_state(server_pid)
      old_subscriber_state = hd(old_state)
      assert [] = old_subscriber_state.type.recharges
      assert :ok = GenServer.cast(server_pid, {:make_recharge, "123456789", 100, date})
      new_state = :sys.get_state(server_pid)
      new_subscriber_state = hd(new_state)
      assert [recharge] = new_subscriber_state.type.recharges
      assert 100 == recharge.value
    end

    test "with invalid phone", %{server_pid: server_pid} do
      payload = %{full_name: "John Doe", phone: "123456789", type: :prepaid}
      GenServer.call(server_pid, {:create_subscriber, payload})
      date = Date.utc_today()
      old_state = :sys.get_state(server_pid)
      assert :ok = GenServer.cast(server_pid, {:make_recharge, "0987654321", 100, date})
      new_state = :sys.get_state(server_pid)
      assert old_state == new_state
    end
  end
end
