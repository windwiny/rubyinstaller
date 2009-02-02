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

      # package:version
      Rake::Task.define_task("#{@name}:#{@version}")
      Rake::Task["#{@name}:#{@version}"].comment = "Build #{@name} version #{@version}"

      chained_actions = []
      chained_actions << :download if define_download
      chained_actions << :extract if define_extract

      # prepend package:version to the list of actions
      chained_actions.map! { |action| "#{@name}:#{@version}:#{action}" }

      # package:version => [package:version:...]
      Rake::Task["#{@name}:#{@version}"].enhance(chained_actions)
    end

    def define_download
      return unless @actions.has_downloads?

      # collect all defined tasks in order
      tasks = []

      # sandbox/package/version/before-download_checkpoint
      tasks << action_checkpoint(:before, :download)

      # sandbox/package/version/download_checkpoint
      tasks << Rake::FileTask.define_task(download_checkpoint) do |t|
         FileUtils.touch(t.name)
      end

      @actions.downloads.each do |download|
        Rake::FileTask.define_task("#{pkg_dir}/#{download[:file]}") do |t|
          OneClick::Utils.download(download[:url], pkg_dir)
        end

        # sandbox/package/version/download_checkpoint => [sandbox/package/version/file]
        tasks.last.enhance(["#{pkg_dir}/#{download[:file]}"])
      end

      # sandbox/package/version/after-download_checkpoint
      tasks << action_checkpoint(:after, :download)

      Rake::Task.define_task("#{@name}:#{@version}:download" => tasks.compact)
    end

    def define_extract
      return unless @actions.has_downloads?

      # collect all defined tasks in order
      tasks = []

      # sandbox/package/version/before-extract_checkpoint
      tasks << action_checkpoint(:before, :extract)

      # sandbox/package/version/extract_checkpoint
      tasks << Rake::FileTask.define_task(extract_checkpoint) do |t|
        # Perform file extraction for each prerequisite
        t.prerequisites.each do |f|
          OneClick::Utils.extract(f, source_dir)
        end

        # generate checkpoint file
        FileUtils.touch(t.name)
      end

      @actions.downloads.each do |download|
        # sandbox/package/version/extract_checkpoint => [sandbox/package/version/file]
        tasks.last.enhance(["#{pkg_dir}/#{download[:file]}"])
      end

      # sandbox/package/version/after-download_checkpoint
      tasks << action_checkpoint(:after, :extract)

      # package:version:extract => [sandbox/package/version/extract_checkpoint]
      Rake::Task.define_task("#{@name}:#{@version}:extract" => tasks.compact)
    end

    private

    def sha1_files
      @sha1_files ||= begin; \
        files = @actions.downloads.collect { |download| "#{pkg_dir}/#{download[:file]}" }.join("\n"); \
        Digest::SHA1.hexdigest(files); \
      end
    end

    def action_checkpoint(before_or_after, action)
      actions, persistent_actions = case before_or_after
        when :before
          [@actions.before_parts(action), @actions.persisted_before_parts(action)]
        when :after
          [@actions.after_parts(action), @actions.persisted_after_parts(action)]
      end

      # no actions? nothing for you then!
      return unless actions || persistent_actions

      # package:version:before_or_after-action
      task = Rake::Task.define_task("#{@name}:#{@version}:#{before_or_after}-#{action}")

      if actions then
        task.enhance do |t|
          actions.each { |a| a.call(self) }
        end
      end

      # define action checkpoint for persistent tasks
      if persistent_actions then
        # sha generate based on project, version, action and number of given parts
        sha1 = Digest::SHA1.hexdigest([@name, @version, "#{before_or_after}-#{action}", persistent_actions.size].join("\n"))

        # sandbox/package/version/before_or_after_checkpoint
        checkpoint = Rake::FileTask.define_task(checkpoint_file("#{before_or_after}-#{action}", sha1)) do |t|
          persistent_actions.each { |pa| pa.call(self) }
          FileUtils.touch(t.name)
        end

        # chain the checkpoint to the action task
        # package:version:before_or_after-action => [sandbox/package/version/before_or_after-action-checkpoint]
        task.enhance([checkpoint.name])
      end

      # return the defined task name
      task.name
    end

    def download_checkpoint
      @download_checkpoint ||= checkpoint_file(:download, sha1_files)
    end

    def extract_checkpoint
      @extract_checkpoint ||= checkpoint_file(:extract, sha1_files)
    end

    def checkpoint_file(action, signature)
      "#{pkg_dir}/.checkpoint--#{action}--#{signature}"
    end
  end
end
