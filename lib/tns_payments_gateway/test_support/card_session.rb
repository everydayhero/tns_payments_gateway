require "tns_payments_gateway"

module TNSPaymentsGateway
  module TestSupport
    class CardSession
      SAMPLE_CARDS = {
        mastercard: {
          number: "5123450000000008",
          expiry: {
            month: "5",
            year: "21",
          },
          cvv: "123",
        },
        amex: {
          number: "345678901234564",
          expiry: {
            month: "5",
            year: "21",
          },
          cvv: "1234",
        },
        visa: {
          number: "4005550000000019",
          expiry: {
            month: "5",
            year: "21",
          },
          cvv: "123",
        },
      }

      def self.sample_card(card_type = :visa)
        Hashie::Mash.new(SAMPLE_CARDS.fetch(card_type))
      end

      def self.sample(card_type = :visa, *args)
        sessionize(sample_card(card_type), *args)
      end

      def self.sessionize(card, *args)
        session = new(*args)
        session.store(card: card)
        session.session_id
      end

      def initialize(gateway: nil, facade: nil)
        @facade = facade || Facade.new(
          gateway || TNSPaymentsGateway.current,
        )
      end

      def session_id
        @session_id ||= @facade.new_session_id!
      end

      def store(options = {})
        card = options.fetch(:card)
        @facade.update_session_with_card(session_id, card)
      end

      def retrieve
        @facade.retrieve_session(session_id)
      end
    end
  end

  class Facade
    def session_id_with_card(card_type: :visa)
      session_id_from_card(TestSupport::CardSession.sample_card(card_type))
    end

    def session_id_from_card(card)
      session = TestSupport::CardSession.new(facade: self)
      session.store(card: card)
      session.session_id
    end
  end
end
