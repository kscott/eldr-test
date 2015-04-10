module AssetManager
  module AWS
    class GroupImage < Image
      def legacy_file_path
        "g_#{@object.id}"
      end

      protected

      def file_path
        "group/#{@object.id}"
      end
    end
  end
end
