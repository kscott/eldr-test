module Church
  class BasicEventSerializer < ::Church::BaseSerializer
    schema do
      type "event"

      map_properties :id, :name, :yes_phrase, :no_phrase, :maybe_phrase, :who_phrase

      entity :registration, item do |event, s|
          s.property :status, event.registration_status
          s.property :type, registration_type(event)
          s.property :form_url, form_url(event)
          s.property :capacity, event.registration_limit
          s.property :remaining, event.remaining_registration
          s.property :full, event.full?
        end

      property :show_guest_list, item.show_guest_list?
      property :allow_other_guests, item.allow_other_guests?
      entity :group, item.group, Church::BasicGroupSerializer
    end

    def form_url(event)
      if event.register_via_form?
        # form_path(event.registration_form)
        "/form.php?id=#{event.registration_form.id}"
      else
        nil
      end
    end
    def registration_type(event)
      if event.register_via_form?
        :form
      else
        :rsvp
      end
    end
  end
end
