require "tns_payments_gateway/version"

module TNSPaymentsGateway
  def self.current(marketplace_id = nil)
    Gateway.new(Config.for(marketplace_id, :pay).config)
  end

  def self.facade(marketplace_id: nil, gateway: current(marketplace_id))
    Facade.new gateway
  end
end

require "tns_payments_gateway/config"
require "tns_payments_gateway/gateway"
require "tns_payments_gateway/facade"
