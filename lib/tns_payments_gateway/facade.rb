require "delegate"
require "hashie/mash"
require "tns_payments_gateway/deep_compact"

require "tns_payments_gateway/types"

module TNSPaymentsGateway
  class Facade
    def initialize(gateway)
      @gateway = gateway
    end

    def merchant_id
      @gateway.merchant_id
    end

    def online?
      perform(CheckGateway).status == "OPERATING"
    end

    def create_session
      perform(CreateSession)
    end

    def new_session_id!
      result = create_session

      raise "failed creating a session" if result.result != "SUCCESS"

      result.session.id
    end

    def update_session_with_card(session_id, card)
      perform(
        UpdateSession,
        sessionId: session_id,
        sourceOfFunds: {
          provided: {
            card: {
              number: card.number,
              expiry: {
                month: card.expiry.month,
                year: card.expiry.year,
              },
              securityCode: card.cvv,
            },
          },
        },
      )
    end

    def retrieve_session(session_id)
      perform(
        RetrieveSession,
        sessionId: session_id,
      )
    end

    def pay_with_session_id(order_id, amount, currency, session_id,
                            statement_descriptor: {}, sub_merchant: {},
                            transaction_id: "PAY")
      perform(
        Pay,
        orderId: order_id,
        transactionId: transaction_id,
        sourceOfFunds: {
          type: "CARD",
        },
        session: {
          id: session_id,
        },
        order: TNSPaymentsGateway::DeepCompact.call(
          amount: amount,
          currency: currency,
          statementDescriptor: cast(
            Types::StatementDescriptor,
            statement_descriptor,
          ),
          subMerchant: cast(
            Types::SubMerchant,
            sub_merchant,
          ),
        ),
      )
    end
    alias_method :pay, :pay_with_session_id

    def pay_with_token(order_id, amount, currency, token,
                       statement_descriptor: {}, sub_merchant: {},
                       transaction_id: "PAY")
      perform(
        Pay,
        orderId: order_id,
        transactionId: transaction_id,
        sourceOfFunds: {
          type: "CARD",
          token: token,
        },
        order: TNSPaymentsGateway::DeepCompact.call(
          amount: amount,
          currency: currency,
          statementDescriptor: cast(
            Types::StatementDescriptor,
            statement_descriptor,
          ),
          subMerchant: cast(
            Types::SubMerchant,
            sub_merchant,
          ),
        ),
      )
    end

    def void(order_id, transaction_id: "VOID", target_transaction_id: "PAY")
      perform(
        VoidTransaction,
        orderId: order_id,
        transactionId: transaction_id,
        transaction: {
          targetTransactionId: target_transaction_id,
        },
      )
    end

    def refund(order_id, amount, currency, transaction_id: "REFUND")
      perform(
        RefundTransaction,
        orderId: order_id,
        transactionId: transaction_id,
        transaction: {
          amount: amount,
          currency: currency,
        },
      )
    end

    def retrieve_order(order_id)
      perform(
        RetrieveOrder,
        orderId: order_id,
      )
    end

    def retrieve_transaction(order_id, transaction_id)
      perform(
        RetrieveTransaction,
        orderId: order_id,
        transactionId: transaction_id,
      )
    end

    def tokenize_session_id(session_id)
      perform(
        TokenizeCardSession,
        session: {
          id: session_id,
        },
        sourceOfFunds: {
          type: "CARD",
        },
      )
    end

    def three_d_s_initiate_auth(order_id, transaction_id, currency, session_id,
                                purpose: "PAYMENT_TRANSACTION")
      perform(
        ThreeDSInitiateAuthentication,
        orderId: order_id,
        transactionId: transaction_id,
        authentication: {
          acceptVersions: "3DS1,3DS2",
          channel: "PAYER_BROWSER",
          purpose: purpose,
        },
        order: {
          currency: currency,
        },
        session: {
          id: session_id,
        },
      )
    end

    def three_d_s_authenticate_payer(order_id, transaction_id, currency, amount,
                                     session_id, response_redirect, device)
      perform(
        ThreeDSAuthenticatePayer,
        orderId: order_id,
        transactionId: transaction_id,
        authentication: {
          redirectResponseUrl: response_redirect,
        },
        order: {
          amount: amount,
          currency: currency,
        },
        session: {
          id: session_id,
        },
        device: device,
      )
    end

    private

    def cast(klass, hash)
      hash = Types.cast_hash(klass, hash)

      return nil if hash&.empty?

      hash
    end

    def perform(operation, options = {})
      result operation.new(@gateway).call(
        TNSPaymentsGateway::DeepCompact.call(options) || {},
      )
    end

    def result(hash)
      Hashie::Mash.new hash
    end
  end
end
