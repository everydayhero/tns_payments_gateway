require "tns_payments_gateway"

module TNSPaymentsGateway
  def self.reporting_gateway(marketplace_id = nil)
    ReportingGateway.new(Config.for(marketplace_id, :reporting).config)
  end

  def self.reporting_facade(marketplace_id: nil,
                            gateway: reporting_gateway(marketplace_id))
    ReportingFacade.new(gateway)
  end
end

require "tns_payments_gateway/reporting_gateway"
require "tns_payments_gateway/reporting_facade"
