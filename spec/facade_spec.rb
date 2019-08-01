require "spec_helper"

require "tns_payments_gateway"
require "tns_payments_gateway/test_support/card_session"

module TNSPaymentsGateway
  describe Facade, :vcr do
    subject { TNSPaymentsGateway.facade }

    it "can tell if TNS is online" do
      expect(subject).to be_online
    end

    it "can retrieve a merchant_id" do
      expect(subject.merchant_id).to eq "TESTEVHEROSTG03"
    end

    let(:session_id) { TNSPaymentsGateway::TestSupport::CardSession.sample }
    let(:order_id) { Digest::SHA1.hexdigest(session_id) }
    let(:amount) { "100.00" }
    let(:currency) { "AUD" }
    let(:half_amount) { "50.00" }

    context "payments" do
      let!(:result) do
        subject.pay(order_id, amount, currency, session_id)
      end

      context "with merchant information" do
        let!(:result) do
          subject.pay(order_id, amount, currency, session_id, **extra)
        end

        let(:sub_merchant_id) { Digest::SHA1.hexdigest(order_id) }

        let(:extra) do
          {
            statement_descriptor: {
              address: {
                country: "AUS",
              },
              name: "Charity McCharityFace",
              phone: "555-8675309",
            },
          }
        end

        it "can annotate order with merchant information" do
          order = subject.retrieve_order(order_id)
          descriptor = order.transaction[0].order.statementDescriptor

          expect(descriptor.name).to eq "Charity McCharityFace"
          expect(descriptor.phone).to eq "555-8675309"
          expect(descriptor.address.country).to eq "AUS"
        end
      end

      context "with mastercard" do
        let(:session_id) { TestSupport::CardSession.sample(:mastercard) }

        it "allows purchases" do
          expect(result.order.status).to eq "CAPTURED"
          expect(result.sourceOfFunds.provided.card.brand).to eq "MASTERCARD"
        end
      end

      context "with visa" do
        let(:session_id) { TestSupport::CardSession.sample(:visa) }

        it "allows purchases" do
          expect(result.order.status).to eq "CAPTURED"
          expect(result.sourceOfFunds.provided.card.brand).to eq "VISA"
        end
      end

      context "with amex" do
        let(:session_id) { TestSupport::CardSession.sample(:amex) }

        it "allows purchases" do
          expect(result.order.status).to eq "CAPTURED"
          expect(result.sourceOfFunds.provided.card.brand).to eq "AMEX"
        end
      end

      it "can retrieve details after a purchase" do
        expect(result.order.status).to eq "CAPTURED"
        transaction = subject.retrieve_transaction order_id, "PAY"
        expect(transaction.transaction.receipt).to eq result.transaction.receipt
      end

      it "can void after purchase" do
        void_result = subject.void order_id
        expect(void_result.order.status).to eq "CANCELLED"
      end

      it "can refund after purchase" do
        refund_result = subject.refund order_id, amount, currency
        expect(refund_result.order.status).to eq "REFUNDED"
      end

      it "can perform partial refunds" do
        refund_result = subject.refund order_id, half_amount, currency
        expect(refund_result.order.status).to eq "PARTIALLY_REFUNDED"
      end

      it "can retrieve order information" do
        order = subject.retrieve_order(order_id)
        expect(order.status).to eq "CAPTURED"
        expect(order.totalAuthorizedAmount).to eq 100.0
        expect(order.totalCapturedAmount).to eq 100.0
        expect(order.totalRefundedAmount).to eq 0.0

        subject.refund order_id, half_amount, currency
        order = subject.retrieve_order(order_id)
        expect(order.status).to eq "PARTIALLY_REFUNDED"
        expect(order.totalRefundedAmount).to eq 50.0

        subject.refund(
          order_id,
          half_amount,
          currency,
          transaction_id: "REFUND2",
        )
        order = subject.retrieve_order(order_id)
        expect(order.status).to eq "REFUNDED"
        expect(order.totalRefundedAmount).to eq 100.0
      end
    end

    it "can use region-specific gateways" do
      region1 = TNSPaymentsGateway.facade(marketplace_id: "au")
      region2 = TNSPaymentsGateway.facade(marketplace_id: "uk")

      session1 = region1.session_id_with_card
      session2 = region2.session_id_with_card

      expect(region1.retrieve_session(session1).merchant)
        .to eq "TESTEVHEROSTG03"
      expect(region2.retrieve_session(session2).merchant)
        .to eq "TESTEVEDAYHSBC01"
      expect(region1.retrieve_session(session2).result).to eq "ERROR"
      expect(region2.retrieve_session(session1).result).to eq "ERROR"
    end

    it "can initiate three-d-s auth" do
      pre_auth = subject.three_d_s_initiate_auth(order_id, order_id, currency,
                                                 session_id)

      expect(pre_auth.response.gatewayRecommendation)
        .to eq "PROCEED_WITH_AUTHENTICATION"
      expect(pre_auth.authentication.redirectHtml).not_to be_nil
    end

    context "tokenization" do
      let(:amount) { "100.00" }
      let(:currency) { "AUD" }

      it "allows purchasing with a tokenized session_id" do
        with_tokenizing_profile do
          facade = TNSPaymentsGateway.facade(marketplace_id: "au")
          session_id = TestSupport::CardSession.sample(:visa, facade: facade)
          order_id = Digest::SHA1.hexdigest(session_id)
          token = facade.tokenize_session_id(session_id).token
          result = facade.pay_with_token(order_id, amount, currency, token)

          expect(result.order.status).to eq("CAPTURED")
          expect(result.sourceOfFunds.provided.card.brand).to eq("VISA")
          expect(result.sourceOfFunds.token).to eq(token)
        end
      end
    end
  end
end
