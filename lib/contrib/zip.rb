# push contrib/archive into search path
contrib_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(contrib_dir) unless $LOAD_PATH.include?(contrib_dir)

# load rubyzip 0.9.1
require 'zip/zip'

# Use fileutils
require 'fileutils'

# simplified extraction method
module Zip
  def self.extract(zip_file, destination)
    puts "unzip -o #{zip_file} -d #{destination}"

    Zip::ZipFile.open(zip_file) do |zf|
      zf.each do |entry|
        target = File.join(destination, entry.name)

        # Ensure the destination path exists
        FileUtils.mkpath(File.dirname(target))

        # extract (and overwrite)
        zf.extract(entry, target) { true }
      end
    end
  end
end
