module OneClick
  class Package
    class Actions
      autoload :URI, 'uri'

      attr_reader :downloads

      def initialize
        @downloads = []
      end

      def download(url)
        resource = URI.parse(url)
        @downloads << { :file => File.basename(resource.path), :url => url }
      end

      def has_downloads?
        @downloads.size > 0
      end
    end
  end
end
