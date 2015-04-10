module Church
  class Individual < ::Church::Base
    scope :active, -> { where("individual.inactive != '1'") }
    SITE_KEY = "283136f4c0a55d06821f8dd236a4ddef"
    # devise :database_authenticatable
    self.table_name = "individual"
    belongs_to :campus
    has_many :individual_groups
    has_many :groups, through: :individual_groups
    has_many :individual_events
    has_many :events, through: :individual_events
    has_many :notes
    has_one :mobile_carrier, primary_key: :phone_mobile_sms_carrier_id, foreign_key: :id, class_name: "::Church::Lists::MobileCarrier"
    belongs_to :family
    has_many :family_members, ->(individual) { where.not id: individual.id }, through: :family, source: :members
    has_many :assignments, class_name: "ScheduleDetailAssignment"
    has_many :attendance_records, class_name: EventAttendee
    has_one :extra_info, class_name: ::Church::Individual::ExtraInfo

    alias_attribute :encrypted_password, :hashed_password
    alias_attribute :encrypted_password=, :hashed_password=

    alias_attribute :first_name, :name_first
    alias_attribute :first_name=, :name_first=
    alias_attribute :last_name, :name_last
    alias_attribute :last_name=, :name_last=

    alias_attribute :last_login, :last_login_date

    def name
      "#{first_name} #{last_name}"
    end

    def active?
      inactive != "1"
    end

    def limited?
      limited_access_user == "1"
    end

    def set_communication_prefs?
      ind_has_updated_comm_settings == "1"
    end

    def full_name
      name = self.name
      name = "#{name} #{name_suffix}" unless name_suffix.blank?
      name = "#{name_prefix} #{name}" unless name_prefix.blank?

      name
    end

    def couple_salutation
      salutation = ""
      if family_leader?
        if spouse
          if primary_contact?
            primary = self
            secondary = spouse
          else
            primary = spouse
            secondary = self
          end

          if primary.last_name == secondary.last_name
            salutation = "#{primary.first_name} and #{secondary.first_name} #{primary.last_name}"
          else
            salutation = "#{primary.name} and #{secondary.name}"
          end
        end
      end

      salutation
    end

    def email
      email_primary
    end

    def phone
      unless phone_mobile.blank?
        phone_mobile
      else
        phone_contact
      end
    end

    %w(contact home mobile work emergency fax pager).each do |type|
      define_method("#{type}_phone") do
        self.send "phone_#{type}"
      end
      define_method("#{type}_phone=") do |value|
        self.send "phone_#{type}=", value
      end
    end

    def primary_contact
      if primary_contact?
        self
      else
        family.select {|f| f.family_position == 'h'}.first
      end
    end

    def spouse
      family_members.select {|f| f.family_leader? }.first if family_leader?
    end

    def children
      family_members.select {|f| f.family_position == 'c'}
    end

    def others
      family_members.select {|f| f.family_position == 'o'}
    end

    def family_leader?
      primary_contact? || spouse?
    end

    def primary_contact?
      family_position == 'h'
    end

    def spouse?
      family_position == 's'
    end

    def mailing_address
      {
        street: mailing_street,
        city: mailing_city,
        state: mailing_state,
        zip: mailing_zip
      }
    end
    alias :address :mailing_address

    def tokens
      {access: token_access, document: token_doc, rss: token_rss}
    end

    def asset_manager(type)
      if type == :files
        @individual_files ||= ::AssetManager::build(type: :individual_files, object: self, organization: ::Company::OrganizationApplication.current)
      elsif type == :image
        @individual_images ||= ::AssetManager::build(type: :individual_image, object: self, organization: ::Company::OrganizationApplication.current)
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


    def image_exists?
      !image_uploaded.blank?
    end

    def legacy_image_exists?
      !picture.empty?
    end

    def groups_led
      groups.where(individual_groups: {status_id: 1})
    end

    def led_by?(leader)
      leader.leads?(self)
    end

    def leads?(individual)
      id = if individual.is_a? self.class
             individual.id
           else
             individual
           end
      individuals_led.include?(id)
    end

    def individuals_led
      unless @individuals_led
        @individuals_led = Church::IndividualGroup.where(group_id: self.individual_groups.is_leader.pluck(:group_id)).collect {|g| g.individual_id}.uniq
      end

      @individuals_led
    end

    def visible_notes
      notes
    end

    def update_profile(attributes)
      assign_attributes attributes

      if email_primary_changed? && !email_primary_was.blank?
        individual_email = Email::IndividualController.new
        subject = "Email Successfully Changed"

        individual_email.context = {
          subject: subject,
          individual: self,
          campus: campus,
          organization: Company::OrganizationApplication.current
        }

        message = Email::Message.new(
          subject: subject,
          body: individual_email.email_changed,
          sender: Individual.current.to_sender
        )

        recipients = [Email::Recipient.new(to_email.merge(email: email_primary_was))]

        Email.send(recipients: recipients, message: message)
      end

      save!
    end

    def create_note(attributes)
      sharing_level = Church::Note.sharing_levels[attributes[:sharing_level].to_s]
      context = attributes[:context] || Church::Note::CONTEXTS[:general]
      context_id = attributes[:context_id] || 0

      note = Church::Note.new(
        note: attributes[:content],
        date: attributes[:date],
        sharing_level: sharing_level,
        context: context,
        context_id: context_id
      )

      self.notes << note
      self.save!

      note
    end

    def save_photo(photo)
      if asset_manager(:image) << photo
        self.image_uploaded = "1"
        self.picture = asset_manager(:image).legacy_file_path
        self.save!

        all_images
      else
        raise "Unable to upload your photo at this time."
      end
    end

    def record_login(user_agent = "")
      @skip_modified = true

      self.last_login_date = Time.now
      self.last_login_http_user_agent = user_agent if user_agent
      self.date_modified = date_modified
      self.save!
    end

    def to_email
      birthday_hash = {}
      email_hash = {}
      if birthday
        birthday_hash = {birthday: birthday.strftime("%Y-%m-%d")}
      end

      if email_primary
        email_hash = {email: email_primary}
      end

      {
        individual_id: id,
        name: full_name,
        name_first: first_name,
        name_last: last_name,
        token: token_access,
        address_block: ::Presenter::Address.format(mailing_address)
      }.merge(birthday_hash).merge(email_hash)
    end

    def to_sender
      {
          name: full_name,
          email: email_primary.blank? ? "notifications@ccbchurch.com" : email_primary
        }
    end

    def self.current
      Thread.current[:individual]
    end

    def self.current=(individual)
      Thread.current[:individual] = individual
    end

    def self.authenticate(username, password)
      match = nil
      users = find_by_username(username)

      users.each do |user|
        if user && user.hashed_password == ::OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), SITE_KEY, password + user.salt)
          return user
        end
      end
      match
    end

    def self.find_by_username(username)
      where(login: username)
    end

    def self.single_family_search_criteria(value, name = nil)
      allowed_phone_lengths = [7,10]
      barcode_match= arel_table[:checkin_barcode].eq(value)

      search_value = "%#{value}%"
      contact_match = arel_table[:phone_contact].matches(search_value)
      home_match = arel_table[:phone_home].matches(search_value)
      mobile_match = arel_table[:phone_mobile].matches(search_value)
      phone_match = contact_match.or(home_match).or(mobile_match)

      unless name.blank?
        name = "%#{name}%"
        first_name_match = arel_table[:name_first].matches(name)
        last_name_match = arel_table[:name_last].matches(name)
        name_match = first_name_match.or(last_name_match)
      end

      search = barcode_match
      if allowed_phone_lengths.include?(value.size)
        search = search.or(phone_match)
      end
      if name_match
        search = name_match.and(search)
      end

      where(search)
    end

    def has_leadership_role?(identifier, campus)
      role = Company::LeadershipRole.find_by(short_name: identifier)
      leadership_roles.where(process_type_id: role.id, campus: campus).exists?
    end

    def leadership_roles
      @my_roles ||= Company::IndividualLeadershipRole.for_individual(self)
      @my_roles
    end
  end
end
