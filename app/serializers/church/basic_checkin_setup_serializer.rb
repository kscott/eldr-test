module Church
  class BasicCheckinSetupSerializer < ::Church::BaseSerializer
    schema do
      type "checkin_setup"

      map_properties :id, :name, :station_type, :background_image
    end
  end
end
