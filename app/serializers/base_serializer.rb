require 'oat/adapters/church_community_builder'

class BaseSerializer < ::Oat::Serializer
  adapter Oat::Adapters::ChurchCommunityBuilder

  def engagement_week
    Company::OrganizationApplication.current.engagement_week_for
  end
end
