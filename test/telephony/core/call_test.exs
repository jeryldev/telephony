defmodule Telephony.Core.CallTest do
  use ExUnit.Case

  alias Telephony.Core.Call

  describe "new/2" do
    test "with valid params" do
      time_spent = 10
      date = NaiveDateTime.utc_now()
      result = Call.new(time_spent, date)
      expected = %Call{time_spent: 10, date: date}
      assert expected == result
    end

    test "with no date provided" do
      time_spent = 10
      result = time_spent |> Call.new() |> Map.get(:date) |> Map.get(:today)
      expected = Map.get(NaiveDateTime.utc_now(), :today)
      assert expected == result
    end
  end
end
