defprotocol Telephony.Core.Invoice do
  def print(subscriber_type, calls, year, month)
end
