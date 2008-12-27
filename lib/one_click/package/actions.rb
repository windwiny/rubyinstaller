module OneClick
  class Package
    class Actions
      autoload :URI, 'uri'

      attr_reader :downloads
      attr_reader :dependencies

      def initialize
        @downloads = []
        @tools = []
        @dependencies = []
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

      def depends_on(package, options = {})
        @dependencies << { :package => package }.merge(options)
      end

      def has_dependencies?
        @dependencies.size > 0
      end
    end
  end
end
