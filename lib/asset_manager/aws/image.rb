module AssetManager
  module AWS
    class Image
      def initialize(object, organization, client)
        @client = client
        @organization = organization
        @object = object
      end

      # shape = :original, :square
      def path(size = ::AssetManager::IMAGE_SIZES[:medium], shape = :square)
        if @object.image_exists?
          image = @client.bucket.objects["#{key}-#{shape}-#{size}"]
          image.url_for(:read, expires: 900).to_s
        else
          if size == ::AssetManager::IMAGE_SIZES[:thumbnail] && @object.legacy_image_exists?
            legacy_path
          else
            ""
          end
        end
      end

      def legacy_path
        image = @client.bucket.objects["#{legacy_key}"]
        image.url_for(:read, expires: 900).to_s
      end

      def upload(photo)
        Thread.new do
          begin
            image = MiniMagick::Image.read(photo)
            image.combine_options do |i|
              i.auto_orient
              i.strip
            end
            image.run_queue
            bucket_upload("#{key}", image.to_blob)

            conn = Bunny.new(ENV["RABBITMQ_URI"])
            conn.start
            channel = conn.create_channel

            exchange = channel.direct("api.image", durable: true)
            exchange.publish([key, legacy_key].to_json, routing_key: "upload")

            conn.close
          ensure
            ActiveRecord::Base.connection.disconnect! if defined? ActiveRecord::Base
            Inter::Base.connection.disconnect! if defined? Inter::Base
            Company::Base.connection.disconnect! if defined? Company::Base
            Church::Base.connection.disconnect! if defined? Church::Base
            Email::Base.connection.disconnect! if defined? Email::Base
          end
        end

        true
      end
      alias_method :<<, :upload


      def legacy_file_path
        raise NotImplementedError
      end

      protected

      def base_path
        "#{@organization.id}/pics"
      end

      def file_path
        raise NotImplementedError
      end

      def key
        key = base_path
        key += "/" unless file_path[0] == '/'
        key += file_path
      end

      def legacy_key
        legacy_key = base_path
        legacy_key += "/" unless legacy_file_path[0] == '/'
        legacy_key += legacy_file_path
      end

      private

      def upload_square_images(photo)
        AssetManager::IMAGE_SIZES.each_value do |size|
          image = MiniMagick::Image.read(photo)
          image.combine_options do |i|
            i.auto_orient
            i.resize "#{size}^"
            i.gravity "center"
            i.crop "#{size}x#{size}+0+0"
            i.quality 100
          end
          image.format("jpeg")

          bucket_upload("#{key}-square-#{size}", image.to_blob)
        end
      end

      def upload_proportional_images(photo)
        AssetManager::IMAGE_SIZES.each_value do |size|
          image = MiniMagick::Image.read(photo)
          image.combine_options do |i|
            i.auto_orient
            i.resize "#{size}"
            i.quality 100
          end
          image.format("jpeg")

          bucket_upload("#{key}-original-#{size}", image.to_blob)
        end

        # Original Image
        image = MiniMagick::Image.read(photo)
        image.combine_options do |i|
          i.auto_orient
          i.resize "2400x2400>"
          i.quality 100
        end
        image.format("jpeg")
        bucket_upload("#{key}-original", image.to_blob)
      end

      def upload_legacy_image(photo)
        image = MiniMagick::Image.read(photo)
        image.combine_options do |i|
          i.auto_orient
          i.resize "250"
          i.quality 100
        end
        image.format("jpeg")

        bucket_upload(legacy_key, image.to_blob)
      end

      def bucket_upload(name, data)
          @client.bucket.objects[name].write(
            data, 
            acl: :authenticated_read,
            content_type: "image/jpeg"
          )
      end
    end
  end
end
