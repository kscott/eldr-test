module Inter
  class CampusCoordinate < ::Inter::Base
    def self.organizations_in_radius(location)
      latitude = location[:latitude]
      longitude = location[:longitude]
      radius = location[:radius]

      organizations = select("meet_at_latitude, meet_at_longitude, org_id, 3956 * 2 * ASIN(SQRT(POWER(SIN((#{latitude} - abs(meet_at_latitude)) * pi()/180 / 2), 2) + COS(#{latitude} * pi()/180) * COS(abs(meet_at_latitude) * pi()/180) *POWER(SIN((#{longitude} - meet_at_longitude) * pi()/180 / 2), 2))) as distance")
        .where("meet_at_longitude between (:longitude - :radius/abs(cos(radians(:latitude))*69)) and (:longitude + :radius/abs(cos(radians(:latitude))*69))", longitude: longitude, latitude: latitude, radius: radius)
        .where("meet_at_latitude  between (:latitude - (:radius/69))  and (:latitude + (:radius/69))", latitude: latitude, radius: radius)
        .order("distance")

      organizations = organizations.map(&:org_id)
      Company::OrganizationApplication.where(id: organizations)
    end
  end
end
