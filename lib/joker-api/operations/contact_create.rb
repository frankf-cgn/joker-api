require 'active_support/core_ext/hash/keys'

module JokerAPI
  module Operations
    module ContactCreate
      # @param [Hash] fields
      # @option fields [String] :tld TLD where this contact is to be used.
      # @option fields [String] :name Full name, if blank :fname and :lname will be used
      # @option fields [String] :fname First name, required if :name is blank
      # @option fields [String] :lname Last name, required if :name is blank
      # @option fields [String] :title Mr, Mrs, Ms. Optional field.
      # @option fields [Boolean] :individual Whether the contact is an individual or an organisation
      # @option fields [String] :organization Organisation name, Optional if :individual is true.
      # @option fields [String] :email Contacts email address
      # @option fields [String] :address Contact Postal Address
      # @option fields [String] :city Postal City
      # @option fields [String] :state Postal State or Locale. Optional field.
      # @option fields [String] :postal_code Postal Code
      # @option fields [String] :country ISO3166 country code
      # @option fields [String] :phone Telephone number in ITU format
      # @option fields [String] :extension Telephone extension. Optional field.
      # @option fields [String] :fax Fax number. Optional field.
      # @option fields [String] :lang Language for EU contacts. Optional unless :tld is 'eu'.
      # @option fields [String] :app_purpose Application Purpose for US contact. Optional unless :tld is 'us'.
      # @option fields [String] :nexus_category Nexus Category for US contact. Optional unless :tld is 'us'.
      # @option fields [String] :nexus_category_country Nexus Cateory Country for US contact. Optional unless :tld is 'us'.
      # @return [String,False] The contact handle if successful, false on error
      def contact_create(fields = {})
        fields.assert_valid_keys(:tld, :name, :fname, :lname, :title, :individual, :organization, :email,
          :address, :city, :state, :postal_code, :country, :phone, :extension, :fax,
          :lang, :app_purpose, :nexus_category, :nexus_category_country)
        raise ArgumentError, ":organization required if :individual is false" if fields[:individual] && fields[:individual] == false && fields[:organization].blank?
        raise ArgumentError, ":name or :fname and :lname are required" if fields[:name].blank? && fields[:fname].blank? && fields[:lname].blank?

        [:email, :address, :city, :postal_code, :country, :phone].each do |field|
          raise ArgumentError, "field :#{field} is required" if fields[field].blank?
        end

        if fields[:tld] == 'eu'
          raise ArgumentError, "field :lang is required for EU TLD" if fields[:lang].blank?
        end

        if fields[:tld] == 'us'
          [:app_purpose, :nexus_category, :nexus_category_country].each do |field|
            raise ArgumentError, "field :#{field} is required for US TLD" if fields[field].blank?
          end
        end

        fields = fields.dup

        fields['individual'] = fields.delete(:individual) ? 'Y' : 'N'
        fields['postal-code'] = fields.delete(:postal_code)
        fields['name'] ||= [fields.delete(:fname), fields.delete(:lname)].compact.join(" ")

        Array(fields.delete(:address)).each_with_index do |addr, idx|
          break if idx > 2
          fields["address-#{idx + 1}"] = addr
        end

        fields['app-purpose'] = fields.delete(:app_purpose) if fields.has_key?(:app_purpose)
        fields['nexus-category'] = fields.delete(:nexus_category) if fields.has_key?(:nexus_category)
        fields['nexus-category-country'] = fields.delete(:nexus_category_country) if fields.has_key?(:nexus_category_country)

        response = perform_request('contact-create', fields)
        return false unless response.success?

        response.proc_id
      end
    end
  end
end
