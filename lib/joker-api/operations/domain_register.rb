require 'active_support/core_ext/hash/keys'

module JokerAPI
  module Operations
    module DomainRegister
      DEFAULT_OPTIONS = { :status => %(production), :period => 12 } # period in months
      REQUIRED_OPTIONS = [:period, :owner_c, :billing_c, :admin_c, :tech_c, :ns_list]
      VALID_OPTIONS = REQUIRED_OPTIONS + [:autorenew, :language, :registrar_tag]

      # @param [String] domain Domain name to register
      # @param [Hash] options
      # @option options [String] :owner_c Owner contact handle
      # @option options [String] :billing_c Billing contact handle
      # @option options [String] :admin_c Administrative contact handle
      # @option options [String] :tech_c Technical contact handle
      # @option options [Array<String>] :ns_list List of nameservers to use
      def domain_register(domain, options = {})
        raise ArgumentError, "unsupported TLD" unless self.tlds.any? { |tld| domain.end_with?(".#{tld}") }
        options.assert_valid_keys(VALID_OPTIONS)
        options = DEFAULT_OPTIONS.merge(options) # options are essentially dup'd here

        REQUIRED_OPTIONS.each do |key|
          raise ArgumentError, "option :#{key} is required" if options[key].blank?
        end

        options["tech-c"] = options.delete(:tech_c)
        options["owner-c"] = options.delete(:owner_c)
        options["admin-c"] = options.delete(:admin_c)
        options["billing-c"] = options.delete(:billing_c)

        options["ns-list"] = options.delete(:ns_list).join(":")

        response = perform_request('domain-register', options.merge(:domain => domain))
        return false unless response.success?

        response.proc_id
      end

    end
  end
end
