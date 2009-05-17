#
# GCC Recipe
#

# Download Windows GNU GCC to be used as compiler
OneClick::Package.new('gcc', '4.3.3') do
  download 'http://downloads.sourceforge.net/mingw/mingwrt-3.15.2-mingw32-dll.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/mingwrt-3.15.2-mingw32-dev.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/w32api-3.13-mingw32-dev.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/binutils-2.19.1-mingw32-bin.tar.gz'
  download 'http://downloads.sourceforge.net/tdm-gcc/gcc-4.3.3-tdm-1-core.tar.gz'
  download 'http://downloads.sourceforge.net/tdm-gcc/gcc-4.3.3-tdm-1-g++.tar.gz'

  depends_on 'bootstrap'

  # advertise the package location for future references
  after :extract do |pkg|
    OneClick.options.gcc_dir = pkg.source_dir
  end
end

# gcc4 uses the version defined above
task 'gcc4' => ['gcc:4.3.3']
