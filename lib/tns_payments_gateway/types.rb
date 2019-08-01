require "dry-struct"
require "delta_force/deep_compact"

module TNSPaymentsGateway
  module Types
    include Dry.Types(:strict, :nominal, :coercible, default: :strict)

    module_function def optional_string(constraints = {})
      Strict::String
        .constrained(constraints)
        .optional
        .default(nil)
    end

    InvalidHash = ::Class.new(StandardError)

    module_function def cast_hash(struct_class, hash)
      DeltaForce::DeepCompact.call(struct_class.new(hash).to_hash)
    rescue Dry::Struct::Error
      raise InvalidHash
    end

    BankIndustryCode = optional_string(format: /^[0-9]{4}$/)
    Email = optional_string
    ISOCode = optional_string(format: /^[A-Z]{3}$/)
    PostCode = optional_string(format: /^[- 0-9a-zA-Z]{1,10}$/)
    String100 = optional_string(min_size: 1, max_size: 100)
    String20 = optional_string(min_size: 1, max_size: 20)

    class Address < Dry::Struct
      schema schema.strict

      attribute :city, String100
      attribute :company, String100
      attribute :country, ISOCode
      attribute :postcodeZip, PostCode
      attribute :stateProvince, String20
      attribute :street, String100
      attribute :street2, String100
      attribute :phone, String20
    end

    OptionalAddress = Address.optional.default { Address.new }

    class StatementDescriptor < Dry::Struct
      schema schema.strict

      attribute :address, OptionalAddress
      attribute :name, String100
      attribute :phone, String20
    end

    class SubMerchant < Dry::Struct
      schema schema.strict

      attribute :address, OptionalAddress
      attribute :bankIndustryCode, BankIndustryCode
      attribute :email, Email
      attribute :identifier, String100
      attribute :phone, String20
      attribute :registeredName, String100
      attribute :tradingName, String100
    end
  end
end
