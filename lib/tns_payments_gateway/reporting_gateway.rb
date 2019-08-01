require "tns_payments_gateway/gateway"
require "tns_payments_gateway/operations/history"

module TNSPaymentsGateway
  class ReportingGateway < Gateway
    def initialize(host:, merchant_id:, api_key:)
      super
      @version = 1
    end

    def path_for(path)
      [
        "/history/version/#{@version}",
        path,
      ].join.sub("{merchantId}", @merchant_id)
    end

    private

    def http_username
      "merchant.default"
    end
  end
end
