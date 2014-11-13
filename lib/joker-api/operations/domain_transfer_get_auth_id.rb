module JokerAPI
  module Operations
    module DomainTransferGetAuthId
      def domain_transfer_get_auth_id(domain)
        response = perform_request('domain-transfer-get-auth-id', :domain => domain)
        return false unless response.success?

        response.proc_id
      end

    end
  end
end
