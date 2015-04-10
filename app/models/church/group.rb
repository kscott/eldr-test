module Church
  class Group < ::Church::Base
    default_scope { where("groups.inactive != '1'") }
    belongs_to :campus
    belongs_to :department, foreign_key: :grouping_id
    belongs_to :group_type, foreign_key: :type_id
    has_many :group_events
    has_many :events, through: :group_events
    has_many :individual_groups, -> { joins(:individual).where.not(individual: {inactive: 1}) }
    has_many :individuals, through: :individual_groups
    belongs_to :coach, foreign_key: :coach_id, class_name: Individual
    belongs_to :director, foreign_key: :director_id, class_name: Individual

    def participants
      @participants ||= individual_groups.includes(:individual).where(status_id: [Church::IndividualGroup.status_ids[:leader], Church::IndividualGroup.status_ids[:member]])
    end

    def leaders
      individual_groups.includes(:individual).where(status_id: Church::IndividualGroup.status_ids[:leader])
    end

    def timezone(&block)
      @timezone ||= ActiveSupport::TimeZone.new(campus.timezone)
      if block_given?
        ::Time.use_zone(@timezone, &block)
      else
        @timezone
      end
    end

    def asset_manager(type)
      if type == :files
        @group_files ||= ::AssetManager::build(type: :group_files, object: self, organization: ::Company::OrganizationApplication.current)
      elsif type == :image
        @group_images ||= ::AssetManager::build(type: :group_image, object: self, organization: ::Company::OrganizationApplication.current)
      else
        raise NotImplementedError
      end
    end

    def image(size = :medium, shape = :square)
      asset_manager(:image).path(::AssetManager::IMAGE_SIZES[size], shape)
    end

    def all_images(shape = :square)
      Hash[::AssetManager::IMAGE_SIZES.each_key.map{|size| [size, self.image(size, shape)]}]
    end

    def save_photo(photo)
      if asset_manager(:image) << photo
        self.image_uploaded = "1"
        self.image_web = asset_manager(:image).legacy_file_path
        self.save!

        all_images
      else
        raise "Unable to upload your photo at this time."
      end
    end

    def image_exists?
      !image_uploaded.blank?
    end

    def legacy_image_exists?
      !image_web.blank?
    end

    def participant?(individual)
      ind_group = individual_membership_record(individual)

      if ind_group
        ind_group.participant?
      end
    end

    def leader?(individual)
      ind_group = leaders.find_by(individual_id: individual.id)

      return false unless ind_group

      ind_group.leader?
    end

    def individual_status(individual)
      ind_group = individual_membership_record(individual)
      if ind_group
        ind_group.status
      end
    end

    def individual_membership_record(individual)
      participants.find_by(individual_id: individual.id) if individual
    end

    def meetings(starting, ending=nil)
      starting = timezone.local_to_utc(starting).in_time_zone(timezone)
      if ending
        ending = timezone.local_to_utc(ending).in_time_zone(timezone)
      else
        ending = starting
      end
      Church::Event.occurrences_between(events, starting.beginning_of_day, ending.end_of_day)
    end

    def special_days(starting, ending)
      cal = ::RiCal::Component::Calendar.new
      family_seen = []
      participants.each do |participant|
        unless participant.individual.birthday.nil?
          cal.events << RiCal.Event do
            summary participant.individual.id.to_s
            description participant.individual.name + " Birthday"
            dtstart participant.individual.birthday.to_date
            rrule "FREQ=YEARLY"
          end
        end
        unless participant.individual.anniversary.nil?
          unless family_seen[participant.individual.family_id]
            if participant.individual.spouse
              if participant.individual.primary_contact?
                primary = participant.individual
                secondary = participant.individual.spouse
              else
                primary = participant.individual.spouse
                secondary = participant.individual
              end
              cal.events << RiCal.Event do
                summary [primary.id, secondary.id].join("::")
                description participant.individual.couple_salutation + " Anniversary"
                dtstart participant.individual.anniversary.to_date
                rrule "FREQ=YEARLY"
              end
            else
              primary = participant.individual
              cal.events << RiCal.Event do
                summary participant.individual.id.to_s
                description participant.individual.name + " Anniversary"
                dtstart participant.individual.anniversary.to_date
                rrule "FREQ=YEARLY"
              end
            end
            family_seen[participant.individual.family_id] = true
          end
        end
      end

      days = []
      cal.events.each do |e|
        e.occurrences(starting: starting, before: ending).each do |o|
          name_parts = o.description.split(" ")
          type = name_parts.pop.downcase
          name = name_parts.join(" ")
          ids = o.summary.split("::")
          days << { name: name, type: type, date: o.dtstart, primary_id: ids.first, secondary_id: ids.second }
        end
      end
      days.sort { |a,b| a[:date] <=> b[:date] }
    end
  end
end
