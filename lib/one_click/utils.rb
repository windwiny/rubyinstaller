require 'contrib/uri_ext'
require 'contrib/zip'
require 'fileutils'

module OneClick
  module Utils
    class UnknownFormatError < StandardError; end

    def self.download(url, destination)
      uri = URI.parse(url)

      # build options
      options = {
        :tmp_dir => OneClick.tmp_dir,     # use instead of system temp folder
        :progress => true                 # display download progress
      }

      uri.download(File.join(destination, File.basename(url)), options)
    end

    def self.extract(file, destination)
      # ensure destination exists
      FileUtils.mkpath(destination)

      # check file extensions
      case File.basename(file)
        when /(^.+\.zip$)/
          # use RubyZip to extract file contents
          Zip.extract(file, destination)
        else
          raise UnknownFormatError.new("Unsupported file format for #{file}")
      end
    end
  end
end
