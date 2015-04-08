module Church
  class AddressSerializer < ::Church::BaseSerializer
    schema do
      type "address"
      properties do |p|
        p.street item[:street]
        p.city item[:city]
        p.state item[:state]
        p.zip item[:zip]
      end
    end
  end
end
