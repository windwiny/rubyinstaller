#
# MSYS Recipe
#

# Minimal SYStem is a supplement to MinGW (GCC) to workaround limitation
# of Windows command shell

OneClick::Package.new('msys', '1.0.11') do
  # MSYS core and updated packages
  download 'http://downloads.sourceforge.net/mingw/msysCORE-1.0.11-20080826.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/findutils-4.3.0-MSYS-1.0.11-3-bin.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/MSYS-1.0.11-20090120-dll.tar.gz'
  download 'http://downloads.sourceforge.net/mingw/tar-1.19.90-MSYS-1.0.11-2-bin.tar.gz'

  # tools for building ruby from source (autoconf, perl, bison and dependencies)
  download 'http://downloads.sourceforge.net/mingw/autoconf2.5-2.61-1-bin.tar.bz2'
  download 'http://downloads.sourceforge.net/mingw/autoconf-4-1-bin.tar.bz2'
  download 'http://downloads.sourceforge.net/mingw/perl-5.6.1-MSYS-1.0.11-1.tar.bz2'
  download 'http://downloads.sourceforge.net/mingw/crypt-1.1-1-MSYS-1.0.11-1.tar.bz2'
  download 'http://downloads.sourceforge.net/mingw/bison-2.3-MSYS-1.0.11-1.tar.bz2'

  depends_on 'compiler'

  # patch profile to avoid chdir into $HOME
  after :extract, :persist => true do |pkg|
    profile = File.join(pkg.source_dir, 'etc', 'profile')

    placeholder = Regexp.escape('cd "$HOME"')

    contents = File.read(profile).gsub(%r(#{placeholder})) do |match|
      "# commented to allow calling from current directory\n##{match}"
    end
    File.open(profile, 'w') { |f| f.write(contents) }
  end

  # always update file system file (fstab) for the defined compiler
  # add defined compiler (gcc_dir) into fstab
  # force usr/local since msys is not using it
  after :extract do |pkg|
    fstab = File.join(pkg.source_dir, 'etc', 'fstab')
    usr_local = File.join(OneClick.root_path, pkg.source_dir, 'usr', 'local')
    mingw = File.join(OneClick.root_path, OneClick.options.gcc_dir)

    File.open(fstab, 'w') do |f|
      f.puts "#{mingw} /mingw"
      f.puts "#{usr_local} /usr/local"
    end
  end

  # TODO: hook shell calls, make and make_install
end

# MSYS uses version defined above
task 'msys' => ['msys:1.0.11']
