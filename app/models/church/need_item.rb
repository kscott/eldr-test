module Church
  class NeedItem < ::Church::Base
    self.table_name = "need_item"

    belongs_to :need
    belongs_to :assigned_to, class_name: "Individual", foreign_key: "assigned_to_id"

    def assigned?
      assigned_to_id != 0
    end

    def assigned_to?(individual)
      individual.id == assigned_to_id
    end

    def assign_to(individual)
      self.assigned_to_id = individual.id
      save!
    end

    def unassign
      self.assigned_to_id = 0
      save!
    end
  end
end
