module Api
  module V1
    class BatchBase < Grape::API
      version 'v1', using: :accept_version_header

      mount Churches
    end
  end
end
