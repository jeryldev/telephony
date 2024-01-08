defmodule Telephony.Core.Call do
  defstruct time_spent: nil, date: nil

  def new(time_spent, date \\ NaiveDateTime.utc_now()),
    do: %__MODULE__{time_spent: time_spent, date: date}
end
