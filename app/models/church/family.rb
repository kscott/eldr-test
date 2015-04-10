module Church
  class Family < ::Church::Base
    self.table_name = "family"

    has_many :members, class_name: "Individual"

    def family_name
      "The #{name} Family"
    end

    def primary_contact
      @primary_contact ||= members.find_by(family_position: "h")
    end

    def spouse
      @spouse ||= members.find_by(family_position: "s")
    end

    def children
      @children ||= members.where(family_position: "c")
    end

    def others
      @others ||= members.where(family_position: "o")
    end

    def self.single_family_search(value, name = nil)
      includes(:members).references(:members).merge(Church::Individual.active.single_family_search_criteria(value, name)).distinct
    end
  end
end
