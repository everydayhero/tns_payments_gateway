require "tns_payments_gateway/reporting_columns"

module TNSPaymentsGateway
  class ColumnSpec
    def initialize(columns_hash)
      @columns = columns_hash
    end

    def valid?
      @columns.keys.all? { |column| REPORTING_COLUMNS.include?(column) } &&
        @columns.values.none? { |column| column.include? "," }
    end

    def tns_columns
      @columns.keys.join(",")
    end

    def csv_columns
      @columns.values.join(",")
    end
  end

  class ReportSpec
    def initialize(from, to, column_spec)
      @from = from
      @to = to
      @column_spec = column_spec
    end

    def valid?
      @column_spec.valid?
    end

    def query
      {
        "timeOfRecord.start" => @from.utc.iso8601,
        "timeOfRecord.end" => @to.utc.iso8601,
        "columns" => @column_spec.tns_columns,
        "columnHeaders" => @column_spec.csv_columns,
      }
    end
  end
end

require "tns_payments_gateway/reporting_gateway"

module TNSPaymentsGateway
  class ReportingFacade
    def initialize(gateway)
      @gateway = gateway
    end

    def merchant_id
      @gateway.merchant_id
    end

    SIMPLE_REPORT = ColumnSpec.new(
      "timeOfRecord"     => "time",
      "order.id"         => "order id",
      "transaction.id"   => "transaction id",
      "transaction.type" => "transaction type",
      "result"           => "result",
    )

    def simple_report(from, to)
      retrieve ReportSpec.new(from, to, SIMPLE_REPORT)
    end

    def custom_report(from, to, column_hash)
      retrieve ReportSpec.new(from, to, ColumnSpec.new(column_hash))
    end

    private

    def retrieve(report)
      raise "spec invalid" unless report.valid?
      RetrieveHistory.new(@gateway).call(report.query)
    end
  end
end
