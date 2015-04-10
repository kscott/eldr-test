module Church
  class Position < ::Church::Base
    self.table_name = "position"
    has_many :group_positions
    has_many :groups, through: :group_positions
    has_many :position_gifts
    has_many :spiritual_gifts, through: :position_gifts
    has_many :position_styles
    has_many :styles, through: :position_styles
    belongs_to :leader, foreign_key: 'owner_id', class_name: 'Individual'

    def save_response(individual:, status:, message:"")
      response = Church::IndividualPosition.find_by(position: self, individual: individual)
      if response
        if status == :accepted
          response.fills_currently!
        else
          response.status = status
        end
        response.comment = message
        response.save!

        true
      else
        false
      end
    end

    def group
      groups.first
    end

    def campus
      group.campus
    end

    def send_notification?
      notification == "1"
    end

    def scheduled?
      non_scheduled != "1"
    end
  end
end
