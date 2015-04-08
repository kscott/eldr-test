module Serializers
  module Individual
    def basic_individual_profile(individual)
      properties do |p|
        p.id individual.id
        p.family_id individual.family_id
        p.first_name individual.first_name
        p.last_name individual.last_name
        p.name individual.name
        p.email individual.email
        p.phone individual.phone
        p.mobile_phone individual.mobile_phone
        p.home_phone individual.home_phone
        p.contact_phone individual.contact_phone
        p.birthday individual.birthday
        p.anniversary individual.anniversary
        p.image images(individual)
        p.active individual.active?
        p.limited individual.limited?
        p.tokens individual.tokens
        p.last_login individual.last_login_date
      end
      entity :address, individual.mailing_address, Church::AddressSerializer
      entity :campus, individual.campus, Church::BasicCampusSerializer
      entity :mobile_carrier, individual.mobile_carrier do |carrier, s|
        s.property :id, carrier.id
        s.property :name, carrier.name
      end
    end

    def basic_family_profile(individual)
      property :family_id, individual.family_id
      property :family_position, family_position(individual.family_position)
      entity :spouse, individual.spouse, Church::MinimalIndividualSerializer
      entities :children, individual.children, Church::MinimalIndividualSerializer
    end

    def basic_individual_links(individual)
      link :self, href: individual_path(individual), authorized: IndividualPolicy.new(current_individual, individual).show?
      link :edit, href: individual_path(individual), authorized: IndividualPolicy.new(current_individual, individual).update?
    end

    def family_position(code)
      case code
      when "h"
        :primary_contact
      when "s"
        :spouse
      when "c"
        :child
      else
        :other
      end
    end
  end
end
