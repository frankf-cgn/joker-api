module JokerAPI
  module Operations
    autoload :QueryContactList,     File.expand_path('../operations/query_contact_list.rb', __FILE__)
    autoload :ContactCreate,        File.expand_path('../operations/contact_create.rb', __FILE__)
    autoload :ContactDelete,        File.expand_path('../operations/contact_delete.rb', __FILE__)
    autoload :ContactModify,        File.expand_path('../operations/contact_modify.rb', __FILE__)

    autoload :QueryDomainList,      File.expand_path('../operations/query_domain_list.rb', __FILE__)
    autoload :DomainDelete,         File.expand_path('../operations/domain_delete.rb', __FILE__)
    autoload :DomainModify,         File.expand_path('../operations/domain_modify.rb', __FILE__)
    autoload :DomainOwnerChange,    File.expand_path('../operations/domain_owner_change.rb', __FILE__)
    autoload :DomainRegister,       File.expand_path('../operations/domain_register.rb', __FILE__)
    autoload :DomainRenew,          File.expand_path('../operations/domain_renew.rb', __FILE__)
    autoload :DomainTransferIn,     File.expand_path('../operations/domain_transfer_in.rb', __FILE__)
    autoload :DomainTransferInReseller, File.expand_path('../operations/domain_transfer_in_reseller.rb', __FILE__)
    autoload :DomainTransferGetAuthId,  File.expand_path('../operations/domain_transfer_get_auth_id.rb', __FILE__)

    autoload :DomainLock,           File.expand_path('../operations/domain_lock.rb', __FILE__)
    autoload :DomainUnlock,         File.expand_path('../operations/domain_unlock.rb', __FILE__)

    autoload :DomainGetProperty,    File.expand_path('../operations/domain_get_property.rb', __FILE__)
    autoload :DomainSetProperty,    File.expand_path('../operations/domain_set_property.rb', __FILE__)

    autoload :QueryNsList,          File.expand_path('../operations/query_ns_list.rb', __FILE__)
    autoload :NsCreate,             File.expand_path('../operations/ns_create.rb', __FILE__)
    autoload :NsDelete,             File.expand_path('../operations/ns_delete.rb', __FILE__)
    autoload :NsModify,             File.expand_path('../operations/ns_modify.rb', __FILE__)

    autoload :QueryWhois,           File.expand_path('../operations/query_whois.rb', __FILE__)

    autoload :ResultRetrieve,       File.expand_path('../operations/result_retrieve.rb', __FILE__)
    
    autoload :WhoisAccreditation,   File.expand_path('../operations/whois_accreditation.rb', __FILE__)
  end
end
