module AssetManager
  module AWS
    class IndividualImage < Image
      def legacy_file_path
        if @object.picture
          "#{@object.picture}"
        else
          "ipic_#{@object.id}"
        end
      end

      protected

      def file_path
        "individual/#{@object.id}"
      end
    end
  end
end
