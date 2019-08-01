require "spec_helper"

require "tns_payments_gateway/test_support/card_session"

module TNSPaymentsGateway
  module TestSupport
    describe CardSession, :vcr do
      subject do
        CardSession.new
      end

      it "should have a session_id" do
        expect(subject.session_id).to match(/SESSION\d+/)
      end

      it "should store a card" do
        subject.store(card: CardSession.sample_card(:visa))
      end

      describe ".sessionize" do
        it "sessionizes arbitrary card data" do
          session = CardSession.sessionize(
            CardSession.sample_card(:visa),
          )
          expect(session).to match(/SESSION\d+/)
        end
      end
    end
  end
end
