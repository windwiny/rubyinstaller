module OneClick
  class Package
    class Actions
      autoload :URI, 'uri'

      attr_reader :downloads

      def initialize
        @downloads = []
        @tools = []
      end

      def download(url)
        resource = URI.parse(url)
        @downloads << { :file => File.basename(resource.path), :url => url }
      end

      def has_downloads?
        @downloads.size > 0
      end

      def uses(tool)
        @tools << tool unless uses?(tool)
      end

      def uses?(tool)
        @tools.include?(tool)
      end
    end
  end
end
