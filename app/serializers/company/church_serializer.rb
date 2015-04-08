module Company
  class ChurchSerializer < ::Company::BaseSerializer
    schema do
      type "church"
      map_properties :subdomain, :name
      property :color, "##{item.color_primary}"
      property :login_text, item.login_page_text
    end
  end
end
