require "tns_payments_gateway/operations/http"

module TNSPaymentsGateway
  class Tokenization < Operation
    include AuthenticatedOperation
  end

  class TokenizeCardSession < Tokenization
    include PostOperation

    def path
      "/merchant/{merchantId}/token"
    end
  end
end
