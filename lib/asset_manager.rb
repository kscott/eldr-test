module AssetManager
  def self.build(type:, object:, organization:, adapter: AWS)
    adapter.build(type, object, organization)
  end

  IMAGE_SIZES = {
    thumbnail: 80,
    small: 150,
    medium: 320,
    large: 640,
    extra_large: 1280
  }
end

require_relative "asset_manager/aws"
