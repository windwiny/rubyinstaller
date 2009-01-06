module OneClick
  class Package
    class Actions
      autoload :URI, 'uri'

      attr_reader :downloads

      def initialize
        @downloads = []
        @before_parts = {}
      end

      def download(url)
        resource = URI.parse(url)
        @downloads << { :file => File.basename(resource.path), :url => url }
      end

      def has_downloads?
        @downloads.size > 0
      end

      def before(action, &block)
        (@before_parts[action] ||= []) << block
      end

      def before_parts(action)
        @before_parts[action]
      end
    end
  end
end
