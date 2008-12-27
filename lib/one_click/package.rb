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

      @actions.downloads.each do |download|
        Rake::FileTask.define_task("#{pkg_dir}/#{download[:file]}") do |t|
          OneClick::Utils.download(download[:url], pkg_dir)
        end

        # package:version:download => [sandbox/package/version/file]
        Rake::Task.define_task("#{@name}:#{@version}:download" => ["#{pkg_dir}/#{download[:file]}"])
      end
    end
  end
end
