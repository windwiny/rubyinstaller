#
# 7zip Recipe
#

# To avoid dependency on advanced extraction tools, this recipe grabs
# 7zip binaries for Windows and replace the built-in extract mechanism 
# to allow unpacking of other formats beyond Zip files.

# SevenZip module contains the methods that replace buit-in functionality
# moved into it's own file for readability.

require File.join(File.dirname(__FILE__), 'seven_zip')

OneClick::Package.new('7zip', '4.64') do
  # download task uses OneClick::Utils.extract helper
  download 'http://downloads.sourceforge.net/sevenzip/7za464.zip'

  after :extract do |pkg|
    # Supply the new executable (found inside package/version/source)
    SevenZip.executable = File.join(pkg.source_dir, '7za.exe')

    module OneClick::Utils
      def self.extract(*args)
        SevenZip.extract(*args)
      end
    end
  end
end
