module Church
  class MyGroupSerializer < ::Church::BaseSerializer
    schema do
      type "group"
      basic_group_profile item
      property :status, status
    end

    protected

    def status
      item.individual_status current_individual
    end
  end
end
