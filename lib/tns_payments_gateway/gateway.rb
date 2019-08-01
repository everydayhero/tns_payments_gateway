require "faraday"

module TNSPaymentsGateway
  class Gateway
    def initialize(host:, merchant_id:, api_key:)
      @host = host
      @merchant_id = merchant_id
      @api_key = api_key
      @version = 52
    end

    attr_reader :merchant_id

    def path_for(path)
      [
        "/api/rest/version/#{@version}",
        path,
      ].join.sub("{merchantId}", @merchant_id)
    end

    def connection(authenticated: false)
      conn = Faraday.new(url: @host) do |faraday|
        faraday.adapter :excon
      end

      conn.basic_auth(http_username, http_password) if authenticated

      conn
    end

    private

    def http_username
      "merchant.#{@merchant_id}"
    end

    def http_password
      @api_key
    end
  end
end

require "tns_payments_gateway/operations/all"
