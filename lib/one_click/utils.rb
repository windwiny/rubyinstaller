require 'contrib/uri_ext'

module OneClick
  module Utils
    def self.download(url, destination)
      uri = URI.parse(url)

      # build options
      options = {
        :tmp_dir => OneClick.tmp_dir,     # use instead of system temp folder
        :progress => true                 # display download progress
      }

      uri.download(File.join(destination, File.basename(url)), options)
    end
  end
end
