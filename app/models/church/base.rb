module Church
  class Base < ::ActiveRecord::Base
    self.abstract_class = true

    belongs_to :creator, class_name: "Individual", foreign_key: :creator_id
    belongs_to :modifier, class_name: "Individual", foreign_key: :modifier_id

    before_validation :set_creation_values, on: :create
    around_update :set_modified_values

    def set_creation_values
      individual_id = if Individual.current
                        Individual.current.id
                      else
                        0
                      end
      self.creator_id = individual_id
      self.modifier_id = individual_id
      self.date_created = Time.now
    end

    def set_modified_values
      if skip_set_modified_values?
        before_update = { modifier_id: self.modifier_id, modified_date: self.date_modified }
      else
        if Individual.current
          self.modifier_id = Individual.current.id
        end
        self.date_modified = Time.now
      end

      yield

      reset_modified_values(before_update)
    end

    def reset_modified_values(before_update)
      if skip_set_modified_values?
        self.update_columns(modifier_id: before_update[:modifier_id], date_modified: before_update[:modified_date])
      end
      reset_skip_modified
    end

    def creator_name
      creator.name if creator
    end

    def modifier_name
      modifier.name if modifier
    end

    def skip_set_modified_values?
      @skip_modified && @skip_modified == true
    end

    def reset_skip_modified
      remove_instance_variable(:@skip_modified) if instance_variable_defined?(:@skip_modified)
    end
  end
end
