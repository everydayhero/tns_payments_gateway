# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tns_payments_gateway"
  spec.version       = "0.0.1unbuilt"
  spec.authors       = ["EDH Payments Team"]
  spec.email         = ["payments@everydayhero.com.au"]
  spec.summary       = "EDH TNS Payments Gem"
  spec.description   = spec.summary

  spec.files         = %x(git ls-files -z 2>/dev/null).split("\x0")
  spec.bindir        = "script"
  spec.executables   = spec.files.grep(%r{^script/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock", ">= 1.19"
  spec.add_development_dependency "dotenv"

  spec.add_dependency "activesupport", "~> 5.1.0"
  spec.add_dependency "faraday"
  spec.add_dependency "excon", "~> 0.40"
  spec.add_dependency "hashie", "~> 3.5.7"
  spec.add_dependency "dry-struct", "~> 0.7.0"
  spec.add_dependency "uri_config", "~> 0.0.4"
  spec.add_dependency "excon_encoding_helper"
end
