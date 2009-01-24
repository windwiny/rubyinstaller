module OneClick
  class Package
    class Actions
      autoload :URI, 'uri'

      attr_reader :downloads

      def initialize
        @downloads = []
        @before_parts = {}
        @after_parts = {}
        @persisted_before_parts = {}
        @persisted_after_parts = {}
      end

      def download(url)
        resource = URI.parse(url)
        @downloads << { :file => File.basename(resource.path), :url => url }
      end

      def has_downloads?
        @downloads.size > 0
      end

      def before(action, options = {}, &block)
        collection = options[:persist] ? @persisted_before_parts : @before_parts
        (collection[action] ||= []) << block
      end

      def after(action, options = {}, &block)
        collection = options[:persist] ? @persisted_after_parts : @after_parts
        (collection[action] ||= []) << block
      end

      def before_parts(action)
        @before_parts[action]
      end

      def after_parts(action)
        @after_parts[action]
      end

      def persisted_before_parts(action)
        @persisted_before_parts[action]
      end

      def persisted_after_parts(action)
        @persisted_after_parts[action]
      end
    end
  end
end
