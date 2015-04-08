module Serializers
  module Group
    def basic_group_profile(group)
      minimal_group_profile(group)
      property :image, images(group)
      basic_group_links(group)
    end

    def minimal_group_profile(group)
      properties do |p|
        p.id group.id
        p.name group.name
      end
      entity :campus, group.campus, Church::BasicCampusSerializer
    end

    def basic_group_links(group)
      link :self, href: group_path(group), authorized: GroupPolicy.new(current_individual, group).show?
      link :edit, href: group_path(group), authorized: GroupPolicy.new(current_individual, group).update?
      link :save_photo, href: group_photos_path(group), authorized: GroupPhotoPolicy.new(current_individual, group).update?
    end
  end
end
