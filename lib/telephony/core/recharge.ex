defmodule Telephony.Core.Recharge do
  defstruct value: nil, date: nil

  def new(value, date \\ NaiveDateTime.utc_now()), do: %__MODULE__{value: value, date: date}
end
