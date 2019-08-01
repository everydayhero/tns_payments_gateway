require "dotenv"
Dotenv.load

require "tns_payments_gateway/config"
require "vcr"
VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :body, :host],
    record: :once,
  }
  c.configure_rspec_metadata!

  ENV.keys.grep(/(PAY|REPORTING)_URL$/).each do |env|
    TNSPaymentsGateway::Config.configure_from(env) do |e|
      e.config.each do |key, value|
        variable = "<#{env}:#{key.to_s.upcase}>"
        c.filter_sensitive_data(variable) { value }
      end
    end
  end
end

# rubocop:disable Metrics/LineLength
def with_tokenizing_profile
  with_env("AU_TNS_PAY_URL", "https://TESTEVHEROSTG02:e750f25acd207d168117d1050e6fbaf7@secure.ap.tnspayments.com") do
    yield
  end
end
# rubocop:enable Metrics/LineLength

def with_env(name, value)
  previous = ENV[name]
  ENV[name] = value
  yield
ensure
  ENV[name] = previous
end
