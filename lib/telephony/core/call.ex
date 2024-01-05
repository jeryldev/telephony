defmodule Telephony.Core.Call do
  defstruct time_spent: nil, date: nil

  def new(time_spent, date) do
    struct(__MODULE__, time_spent: time_spent, date: date)
  end
end
