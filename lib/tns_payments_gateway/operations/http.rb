require "json"
require "excon_encoding_helper"

module TNSPaymentsGateway
  class Operation
    def initialize(gateway)
      @gateway = gateway
    end

    def call(other_options = {})
      my_options = options.merge(other_options)
      response = connection.send(method, actual_path(my_options)) do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = my_options.to_json unless method == :get
      end
      data = ExconEncodingHelper.read_body(response)
      JSON.parse data
    end

    private

    def options
      {}
    end

    def actual_path(options)
      parameterized_path.gsub(/{([^}]+)}/) do |_key|
        value = options.fetch($1.to_sym)
        options.delete($1.to_sym)
        value
      end
    end

    def connection
      @gateway.connection
    end

    def parameterized_path
      @gateway.path_for(path)
    end
  end

  module AuthenticatedOperation
    def connection
      @gateway.connection(authenticated: true)
    end
  end

  module GetOperation
    def method
      :get
    end
  end

  module PostOperation
    def method
      :post
    end
  end

  module PutOperation
    def method
      :put
    end
  end
end
