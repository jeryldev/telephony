defprotocol Telephony.Core.Invoice do
  @fallback_to_any true

  def print(subscriber_type, calls, year, month)
end
