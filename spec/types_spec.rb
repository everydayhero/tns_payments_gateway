require "spec_helper"

require "tns_payments_gateway"
require "tns_payments_gateway/types"

module TNSPaymentsGateway
  RSpec.describe(Types) do
    let(:sub_merchant) do
      {
        address: {
          country: "AUS",
        },
        bankIndustryCode: "1234",
        registeredName: "Blahco",
        tradingName: "Blahco Charity",
      }
    end

    let(:statement_descriptor) do
      {
        address: {
          country: "AUS",
        },
        name: "Foo Fooco",
        phone: "555-8675309",
      }
    end

    let(:bad_hash) do
      {
        badAttribute: "bad",
      }
    end

    context "SubMerchant" do
      it "accepts good hashes" do
        expect(
          Types.cast_hash(Types::SubMerchant, sub_merchant),
        ).to eq(sub_merchant)
      end

      it "rejects bad hashes (invalid keys)" do
        expect do
          Types.cast_hash(Types::SubMerchant, sub_merchant.merge(bad_hash))
        end.to raise_error(Types::InvalidHash)
      end

      it "rejects more bad hashes (invalid data)" do
        expect do
          Types.cast_hash(
            Types::SubMerchant,
            sub_merchant.merge(bankIndustryCode: "12345"),
          )
        end.to raise_error(Types::InvalidHash)
      end
    end

    context "StatementDescriptor" do
      it "accepts good hashes" do
        expect(
          Types.cast_hash(Types::StatementDescriptor, statement_descriptor),
        ).to eq(statement_descriptor)
      end

      it "rejects bad hashes" do
        expect do
          Types.cast_hash(
            Types::StatementDescriptor,
            statement_descriptor.merge(bad_hash),
          )
        end.to raise_error(Types::InvalidHash)
      end
    end
  end
end
