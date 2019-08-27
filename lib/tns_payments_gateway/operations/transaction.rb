require "tns_payments_gateway/operations/http"

module TNSPaymentsGateway
  class OrderOperation < Operation
    include AuthenticatedOperation

    def path
      "/merchant/{merchantId}/order/{orderId}"
    end
  end

  class RetrieveOrder < OrderOperation
    include GetOperation
  end

  class TransactionOperation < OrderOperation
    def path
      super + "/transaction/{transactionId}"
    end
  end

  class Pay < TransactionOperation
    include PutOperation

    def options
      {
        apiOperation: "PAY",
      }
    end
  end

  class VoidTransaction < TransactionOperation
    include PutOperation

    def options
      {
        apiOperation: "VOID",
      }
    end
  end

  class RefundTransaction < TransactionOperation
    include PutOperation

    def options
      {
        apiOperation: "REFUND",
      }
    end
  end

  class RetrieveTransaction < TransactionOperation
    include GetOperation
  end

  class ThreeDSInitiateAuthentication < TransactionOperation
    include PutOperation

    def options
      {
        apiOperation: "INITIATE_AUTHENTICATION",
      }
    end
  end

  class ThreeDSAuthenticatePayer < TransactionOperation
    include PutOperation

    def options
      {
        apiOperation: "AUTHENTICATE_PAYER",
      }
    end
  end
end
