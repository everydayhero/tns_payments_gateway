require "spec_helper"

require "tns_payments_gateway/reporting"
require "csv"

module TNSPaymentsGateway
  describe ReportingFacade, :vcr do
    it "should work" do
      facade = TNSPaymentsGateway.reporting_facade
      from = Time.utc(2016, 9, 8)
      to = Time.utc(2016, 9, 9)
      report = facade.simple_report(from, to)

      data = CSV.new(report, headers: true, header_converters: :symbol).read
      expect(data.size).to eq 3

      row = OpenStruct.new(data.first.to_hash)
      expect(row.order_id).to eq "1284114-3496"
      expect(row.transaction_id).to eq "1284114-3496"
      expect(row.transaction_type).to eq "PAYMENT"
      expect(row.result).to eq "SUCCESS"
    end

    it "should return multiple results for suspect transactions", :skip do
      pending "this situation hasn't happened on the test account yet"
      facade = TNSPaymentsGateway.reporting_facade
      from = Time.parse("2014-07-26T11:45:12Z")
      to = Time.parse("2014-07-26T11:46:12Z")
      report = facade.custom_report(
        from,
        to,
        "timeOfRecord" => "time",
        "transaction.id" => "transaction id",
        "transaction.type" => "transaction type",
        "response.gatewayCode" => "gateway code",
      )

      data = CSV.new(report, headers: true, header_converters: :symbol).read
      row1 = data.by_row[0]
      row2 = data.by_row[1]

      expect(row1[:gateway_code]).to eq "UNKNOWN"
      expect(row2[:gateway_code]).to eq "DECLINED"

      hash1 = row1.to_hash
      hash1.delete(:gateway_code)
      hash2 = row2.to_hash
      hash2.delete(:gateway_code)
      expect(hash1).to eq hash2
    end

    it "can use region-specific gateways" do
      region1 = TNSPaymentsGateway.reporting_facade(marketplace_id: "au")
      region2 = TNSPaymentsGateway.reporting_facade(marketplace_id: "uk")

      from = Time.utc(2016, 9, 8)
      to = Time.utc(2016, 9, 9)

      report1 = region1.simple_report(from, to)
      report2 = region2.simple_report(from, to)

      expect(report1.lines.size).to eq 4
      expect(report2.lines.size).to eq 109
    end
  end
end
