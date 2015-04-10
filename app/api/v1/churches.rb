module Api
  module V1
    class Churches < Grape::API
      # doorkeeper_for :all

      helpers do
        def organization_host(subdomain)
          "#{subdomain}.ccbchurch.com"
        end

        def load_balancer
          ENV["LOAD_BALANCER"]
        end
      end

      namespace :churches do

        desc "Get a listing of organizations by location"
        params do
          optional :location, type: Hash, desc: "Churches within a given radius" do
            requires :latitude, type: Float, desc: "Current latitude"
            requires :longitude, type: Float, desc: "Current longitude"
            optional :radius, type: Integer, values: (1..100).to_a, desc: "The radius in miles out to look"
          end
          optional :name, type: String, desc: "Partial name search"
          optional :subdomain, type: String, desc: "Partial subdomain search"
          exactly_one_of :location, :name, :subdomain
        end
        get do
          begin
            if declared_params[:location]
              location = declared_params[:location]
              location[:radius] = declared_params[:location].fetch(:radius) { 10 }
              organizations = Inter::CampusCoordinate.organizations_in_radius(location)
            elsif declared_params[:subdomain]
              subdomain = declared_params[:subdomain]
              subdomain.strip!
              raise "Subdomain cannot be empty" if subdomain.empty?
              organizations = Company::OrganizationApplication.partial_subdomain(subdomain)
            else
              name = declared_params[:name]
              name.strip!
              raise "Name cannot be empty" if name.empty?
              organizations = Company::OrganizationApplication.partial_name(name)
            end
            CollectionSerializer.new(organizations, serializer_class: Company::ChurchSerializer, total_records: organizations.size)
          rescue RuntimeError => error
            error!({error: error.message}, 400)
          end
        end

        params do
          requires :subdomain, type: String, desc: "Church's subdomain"
        end
        route_param :subdomain, type: String do
          before do
            @organization = Company::OrganizationApplication.find_by_subdomain(declared_params[:subdomain])
            connect_to_church_database(@organization, :read)
            Company::OrganizationApplication.current = @organization
          end

          desc "Get church-wide information"
          get do
            Company::ChurchSerializer.new @organization
          end

          desc "Get campus listing"
          get :campuses do
            campuses = Church::Campus.all
            CollectionSerializer.new(campuses, serializer_class: Church::BasicCampusSerializer, total_records: campuses.size)
          end

          desc "Send user a password reset email", {
            notes: <<-NOTE
            Send a reset password email to the specified email address.

            #### Example

            ```javascript
            {
                email: "you@example.com"
            }
            ```

            #### Response

            Status: 200 OK
            NOTE
          }
          params do
            requires :email, type: String
          end
          post :reset_password do
            conn = Faraday.new(url: load_balancer, headers: {"Host" => organization_host(declared_params[:subdomain])}, ssl: {verify: false}) do |faraday|
              faraday.request  :url_encoded             # form-encode POST params
              faraday.adapter  :net_http                # make requests with Net::HTTP
            end
            begin
              conn.post '/w_password.php', { ax: 'request_forgotten', "section_row[email_primary]".to_sym => declared_params[:email] }
              content_type "application/json"
              status 200
            rescue RuntimeError => error
              error!({error: error.message}, 400)
            end
          end
        end
      end
    end
  end
end
