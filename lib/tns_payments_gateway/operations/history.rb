require "tns_payments_gateway/operations/http"
require "excon_encoding_helper"

module TNSPaymentsGateway
  class RetrieveHistory < Operation
    include AuthenticatedOperation
    include GetOperation

    def path
      "/merchant/{merchantId}/transaction"
    end

    def call(other_options = {})
      my_options = options.merge(other_options)
      response = connection.send(method, actual_path(my_options)) do |req|
        req.params = my_options
      end
      ExconEncodingHelper.read_body(response)
    end
  end
end
