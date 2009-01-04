require 'digest/sha1'

module OneClick
  class Package
    autoload :Actions, 'one_click/package/actions'

    attr_accessor :name
    attr_accessor :version
    attr_accessor :actions

    def initialize(name = nil, version = nil, &block)
      @name = name
      @version = version

      @actions = Actions.new

      if block_given? then
        @actions.instance_eval(&block)

        define
      end
    end

    def pkg_dir
      @pkg_dir ||= File.join(OneClick.sandbox_dir, @name, @version)
    end

    def source_dir
      @source_dir ||= File.join(pkg_dir, 'source')
    end

    def define
      fail 'package name is required' if @name.nil?
      fail 'package version is required' if @version.nil?

      Rake::Task.define_task("#{@name}:#{@version}")
      Rake::Task["#{@name}:#{@version}"].comment = "Build version #{@version} of #{@name}"
    end

    def define_download
      return unless @actions.has_downloads?

      # TODO: define download actions for checkpoint
      Rake::FileTask.define_task(download_checkpoint)

      @actions.downloads.each do |download|
        # TODO: spec file task for coverage
        Rake::FileTask.define_task("#{pkg_dir}/#{download[:file]}") #do |t|
        #  OneClick::Utils.download(download[:url], pkg_dir)
        #end

        # sandbox/package/version/download_checkpoint => [sandbox/package/version/file]
        Rake::Task[download_checkpoint].enhance(["#{pkg_dir}/#{download[:file]}"])
      end

      Rake::Task.define_task("#{@name}:#{@version}:download" => [download_checkpoint])
    end

    def define_extract
      return unless @actions.has_downloads?

      # TODO: define extraction actions for checkpoint
      Rake::FileTask.define_task(extract_checkpoint)

      @actions.downloads.each do |download|
        # sandbox/package/version/extract_checkpoint => [sandbox/package/version/file]
        Rake::Task[extract_checkpoint].enhance(["#{pkg_dir}/#{download[:file]}"])
      end

      # package:version:extract => [sandbox/package/version/extract_checkpoint]
      Rake::Task.define_task("#{@name}:#{@version}:extract" => [extract_checkpoint])
    end

    private

    def sha1_files
      @sha1_files ||= begin; \
        files = @actions.downloads.collect { |download| "#{pkg_dir}/#{download[:file]}" }.join("\n"); \
        Digest::SHA1.hexdigest(files); \
      end
    end

    def download_checkpoint
      @download_checkpoint ||= "#{pkg_dir}/.checkpoint--download--#{sha1_files}"
    end

    def extract_checkpoint
      @extract_checkpoint ||= "#{pkg_dir}/.checkpoint--extract--#{sha1_files}"
    end
  end
end
