module Api
  module V1
    class Queues < Grape::API
      # doorkeeper_for :all, scopes: [:logged_in]

      namespace :queues do
        desc "Return a list of process queues"
        params do
          optional :quick, type: Boolean, default: false
        end
        get do
            queues = QueuePolicy::Scope.new(current_individual, Church::Queue, individual: @individual, organization: organization_application, quick: declared_params[:quick]).resolve
            CollectionSerializer.new(queues, serializer_class: Church::BasicQueueSerializer, total_records: queues.size)
        end

        params do
          requires :id, type: Integer
        end
        route_param :id, type: Integer do
          before do
            @queue = Church::Queue.find(declared_params[:id])
          end

          desc "Get queue information"
          get do
            ::Church::QueueSerializer.new(@queue)
          end

          desc "Get list of individuals in the queue"
          get :individuals do
            individuals = @queue.individuals.includes(:individual_groups, :campus, :family)
            CollectionSerializer.new(individuals, current_individual: current_individual, organization_id: organization_application.id, serializer_class: Church::BasicIndividualSerializer, total_records: individuals.size)
          end

          desc "Add an individual to a process queue"
          params do
            requires :individual_id, type: Integer
            optional :note, type: String
            optional :sharing_level, type: Symbol, values: Church::Note.sharing_levels.keys.map(&:to_sym), default: :context_note, desc: "Note visibility"
          end
          post :individuals do
            writable do
              begin
                individual = Church::Individual.find(declared_params[:individual_id])
                @queue.add_individual(individual)
                if declared_params[:note]
                  attributes = {
                    content: declared_params[:note],
                    date: Time.now.strftime("%Y-%m-%d"),
                    sharing_level: declared_params[:sharing_level],
                    context: Church::Note::CONTEXTS[:queue],
                    context_id: @queue.id
                  }
                  individual.create_note(attributes)
                end
                content_type "application/json"
                header 'Link', "/queues/#{@queue.id}/individuals"
                status 201
              rescue RuntimeError => error
                error!({error: error.message}, 400)
              end
            end
          end
        end
      end
    end
  end
end
