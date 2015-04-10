module AssetManager
  module AWS
    def self.build(type, object, organization)
      client = Client.new

      case type
      when :individual_image
        IndividualImage.new(object, organization, client)
      when :group_image
        GroupImage.new(object, organization, client)
      else
        raise "Unknown asset type: [#{type}]"
      end
    end

    class Client
      def initialize(key: "AKIAJ4CISARDRJPE4ERQ", secret: "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")
        @client = ::AWS::S3.new(
          :access_key_id => key,
          :secret_access_key => secret
        )
      end

      def bucket
        @client.buckets["ccbchurch"]
      end
    end
  end
end

require_relative "aws/image"
require_relative "aws/group_image"
require_relative "aws/individual_image"
