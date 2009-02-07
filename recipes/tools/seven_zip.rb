module SevenZip
  def self.executable=(value)
    @@executable = value
  end

  def self.extract(file, destination)
    # ensure destination exists
    FileUtils.mkpath(destination)

    # use a temporary directory for 2 stages extraction (.tar.*)
    tmpdir = OneClick.tmp_dir

    # ensure temp exists too
    FileUtils.mkpath(tmpdir)

    # check file extensions
    case File.basename(file)
      # tar.z, tar.gz and tar.bz2 contains .tar files inside, extract into 
      # temp first
      when /(^.+\.tar)\.z$/, /(^.+\.tar)\.gz$/, /(^.+\.tar)\.bz2$/
        tar_file = File.join(tmpdir, File.basename($1))
        seven_zip file, tmpdir
        seven_zip tar_file, destination
        FileUtils.rm tar_file
      when /(^.+)\.tgz$/
        tar_file = File.join(tmpdir, "#{File.basename($1)}.tar")
        seven_zip file, tmpdir
        seven_zip tar_file, destination
        FileUtils.rm tar_file
      when /(^.+\.zip$)/
        seven_zip file, destination
      else
        raise UnknownFormatError.new("Unsupported file format for #{file}")
    end

    # Relocate extracted contents if those are inside a versioned folder
    # (msys and ruby packages suffer from this, ruby-1.8.6-p287)
    Dir.glob("#{destination}/*").each do |dir|
      next unless File.directory?(dir) and File.basename(dir) =~ /.*-\d+.*/i

      # ensure relocate normal and dot files
      Dir.glob("#{dir}/**/{*,.*}").each do |entry|
        target = entry.sub(dir, destination)

        # ensure path exists
        File.mkpath File.dirname(target)

        # do not try to relocate directories
        next if File.directory?(entry)
        FileUtils.mv entry, target
      end

      # Remove empty folder
      FileUtils.rm_rf dir
    end
  end

  private

  def self.seven_zip(file, destination)
    #  x: eXtract files with full paths
    # -y: assume Yes on all queries
    args = ['x','-y']

    # -o{Directory}: set Output directory
    args << "-o#{destination}"

    # <archive_name>
    args << file

    puts "7za #{args.join(' ')}"
    output = `#{@@executable} #{args.join(' ')}`
  end
end
