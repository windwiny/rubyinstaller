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
      when /(^.+)\.tgz$/
        tar_file = File.join(tmpdir, "#{File.basename($1)}.tar")
        seven_zip file, tmpdir
        seven_zip tar_file, destination
      when /(^.+\.zip$)/
        seven_zip file, destination
      else
        raise UnknownFormatError.new("Unsupported file format for #{file}")
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

    cmd = "#{@@executable} #{args.join(' ')}"
    puts cmd
    output = `#{cmd}`
  end
end
