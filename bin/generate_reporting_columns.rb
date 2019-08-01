#!/usr/bin/env ruby
# generate_reporting_columns - generate a list of valid reporting columns from
# the TNS API documentation

require 'open-uri'
require 'nokogiri'

URL = "https://secure.ap.tnspayments.com/api/documentation/apiDocumentation/rest-json/version/latest/wadl.xml?locale=en_US"

doc = open(URL) { |f| Nokogiri::XML(f) }

columns = doc.at("doc[@title='Retrieve transaction']").parent
  .search("response representation param").map do |param|
    param[:name].gsub("[n]", "")
  end.reject do |name|
    name == "order.custom" # documented as allowed, isn't
  end

File.open("lib/tns_payments_gateway/reporting_columns.rb", "w") do |f|
  f.puts <<EOR
# This file is generated with bin/generate_reporting_columns.rb, do not edit!
TNSPaymentsGateway::REPORTING_COLUMNS = %w(
  #{columns.join("\n  ")}
)
EOR
end
