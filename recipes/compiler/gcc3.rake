#
# GCC Recipe
#

# Download Windows GNU GCC to be used as compiler
OneClick::Package.new('gcc', '3.4.5') do
  download 'http://downloads.sourceforge.net/mingw/mingwrt-3.15.2-mingw32-dll.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/mingwrt-3.15.2-mingw32-dev.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/w32api-3.13-mingw32-dev.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/binutils-2.19.1-mingw32-bin.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/gcc-core-3.4.5-20060117-3.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/gcc-g++-3.4.5-20060117-3.tar.gz'

  depends_on 'bootstrap'

  # advertise the package location for future references
  after :extract do |pkg|
    OneClick.options.gcc_dir = pkg.source_dir
  end
end

# gcc3 uses the version defined above
task 'gcc3' => ['gcc:3.4.5']
