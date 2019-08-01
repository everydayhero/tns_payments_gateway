require "tns_payments_gateway/operations/http"

module TNSPaymentsGateway
  class CreateSession < Operation
    include PostOperation
    include AuthenticatedOperation

    def path
      "/merchant/{merchantId}/session"
    end
  end

  class SessionOperation < Operation
    include AuthenticatedOperation

    def path
      "/merchant/{merchantId}/session/{sessionId}"
    end
  end

  class UpdateSession < SessionOperation
    include PutOperation
  end

  class RetrieveSession < SessionOperation
    include GetOperation
  end
end
