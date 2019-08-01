# Create an orphaned tns order and refund for testing purposes

tns = TNSPaymentsGateway.facade(marketplace_id: "au")

require "tns_payments_gateway/test_support/card_session"

session_id = tns.session_id_with_card

order_id = Digest::SHA1.hexdigest(session_id)
amount = "10.00"
currency = "AUD"

puts [session_id, order_id, amount, currency]

result = tns.pay(order_id, amount, currency, session_id)

puts result

sleep 10.minutes

tns.refund order_id, amount, currency
