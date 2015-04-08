module Church
  class MobileCarrierSerializer < ::Church::BaseSerializer
    schema do
      map_properties :id, :name
      property :email_domain, item.email
    end
  end
end
