require "uri_config"

module TNSPaymentsGateway
  class Config < URIConfig::Config
    def self.for(region, product)
      env = [
        region,
        :tns,
        product,
        :url,
      ]
        .compact
        .map { |x| x.to_s.upcase.tr("-", "_") }
        .join("_")
      new(ENV.fetch(env))
    end

    map :merchant_id, from: :username
    map :api_key, from: :password
    map :host, from: :base_uri

    config(
      :host,
      :merchant_id,
      :api_key,
    )
  end
end
