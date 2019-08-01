require "active_support/core_ext/object/blank"
require "active_support/core_ext/hash/compact"
require "active_support/core_ext/hash/transform_values"

module TNSPaymentsGateway
  module DeepCompact
    module_function def call(obj)
      case obj
      when Hash
        obj
          .transform_values { |v| call(v) }
          .compact
          .tap { |hash| return nil if hash.empty? }
      when Array
        obj
          .map { |v| call(v) }
          .compact
          .tap { |arr| return nil if arr.empty? }
      else
        obj
      end
    end
  end
end
