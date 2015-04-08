module Church
  class GuestSerializer < ::Church::BaseSerializer
    schema do
      type "guest"
      basic_individual_profile item.individual
    end
  end
end
