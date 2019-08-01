require "tns_payments_gateway/operations/http"

module TNSPaymentsGateway
  class CheckGateway < Operation
    include GetOperation

    def path
      "/information"
    end
  end
end
