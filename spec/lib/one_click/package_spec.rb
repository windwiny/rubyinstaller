require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# DSL construction and Task definitions
describe OneClick::Package do
  describe "#new" do
    it 'should fail if no name for the package was given' do
      lambda {
        OneClick::Package.new { }
      }.should raise_error(RuntimeError, /package name is required/)
    end

    it 'should fail if no version for the package was given' do
      lambda {
        OneClick::Package.new('foo') { }
      }.should raise_error(RuntimeError, /package version is required/)
    end

    it 'should not fail if both name and version for the package was given' do
      lambda {
        OneClick::Package.new('foo', '1.2.3') { }
      }.should_not raise_error(RuntimeError)
    end

    it 'should not attempt to define package if no block was provided' do
      lambda {
        OneClick::Package.new
      }.should_not raise_error(RuntimeError)
    end

    it 'should allow package name be accessed' do
      pkg = OneClick::Package.new('foo', '1.2.3')
      pkg.name.should == 'foo'
    end

    it 'should allow package version be accessed' do
      pkg = OneClick::Package.new('foo', '1.2.3')
      pkg.version.should == '1.2.3'
    end
  end

  describe '#actions' do
    before :each do
      @mock_actions = mock(OneClick::Package::Actions, :has_downloads? => false)
      OneClick::Package::Actions.stub!(:new).and_return(@mock_actions)
    end

    it 'should create an actions instance if a block was provided' do
      OneClick::Package::Actions.should_receive(:new)
      OneClick::Package.new('foo', '1.2.3') { }
    end

    it 'should delegate block to actions instance' do
      a_block = proc { }
      @mock_actions.should_receive(:instance_eval).with(&a_block)
      OneClick::Package.new('foo', '1.2.3', &a_block)
    end

    it 'should create a default actions instance if no block was provided' do
      OneClick::Package::Actions.should_receive(:new).and_return(@mock_actions)
      pkg = OneClick::Package.new('foo', '1.2.3')
      pkg.actions.should == @mock_actions
    end

    it 'should allow package actions be replaced later' do
      pkg = OneClick::Package.new('foo', '1.2.3')
      pkg.actions = nil
      pkg.actions.should be_nil
    end
  end

  describe '#pkg_dir' do
    before :each do
      @pkg = OneClick::Package.new('foo', '4.5.6')
    end

    it 'should use OneClick sandbox definition' do
      OneClick.should_receive(:sandbox_dir).and_return('something')
      @pkg.pkg_dir
    end

    it 'should define a folder structure using name and version' do
      OneClick.stub!(:sandbox_dir).and_return('something')
      @pkg.pkg_dir.should == 'something/foo/4.5.6'
    end
  end

  describe '#source_dir' do
    before :each do
      @pkg = OneClick::Package.new('foo', '1.2.3')
    end

    it 'should use pkg_dir as reference' do
      @pkg.should_receive(:pkg_dir).and_return('sandboxed/foo/1.2.3')
      @pkg.source_dir
    end

    it 'should define a folder inside the structure' do
      @pkg.stub!(:pkg_dir).and_return('tmp/foo/1.2.3')
      @pkg.source_dir.should == 'tmp/foo/1.2.3/source'
    end
  end

  describe '(defining tasks)' do
    before :each do
      Rake.application.clear

      @mock_actions = mock(OneClick::Package::Actions, :has_downloads? => false)
      @mock_actions.stub!(:before_parts => nil,
                          :after_parts => nil,
                          :persisted_before_parts => nil,
                          :persisted_after_parts => nil)

      OneClick::Package::Actions.stub!(:new).and_return(@mock_actions)

      @pkg = OneClick::Package.new('foo', '4.5.6')
    end

    describe "#define" do
      it 'should define a task for the package version' do
        Rake::Task.should_not have_defined('foo:4.5.6')
        @pkg.define
        Rake::Task.should have_defined('foo:4.5.6')
      end

      it 'should invoke download task definition' do
        @pkg.should_receive(:define_download)
        @pkg.define
      end

      it 'should not depend on download task without downloads' do
        @pkg.stub!(:define_download).and_return(false)
        @pkg.define
        Rake::Task['foo:4.5.6'].prerequisites.should_not include('foo:4.5.6:download')
      end

      it 'should add download task as dependency when there are downloads' do
        @pkg.stub!(:define_download).and_return(true)
        @pkg.define
        Rake::Task['foo:4.5.6'].prerequisites.should include('foo:4.5.6:download')
      end

      it 'should invoke extraction task definition' do
        @pkg.should_receive(:define_extract)
        @pkg.define
      end

      it 'should not depend on extraction task without downloads' do
        @pkg.stub!(:define_extract).and_return(false)
        @pkg.define
        Rake::Task['foo:4.5.6'].prerequisites.should_not include('foo:4.5.6:extract')
      end

      it 'should add extraction task when there are things to extract' do
        @pkg.stub!(:define_extract).and_return(true)
        @pkg.define
        Rake::Task['foo:4.5.6'].prerequisites.should include('foo:4.5.6:extract')
      end
    end

    describe "#define_download" do
      before :each do
        OneClick.stub!(:sandbox_dir).and_return('tmp')

        @files = [{:file => 'foo-4.5.6.zip', :url => 'http://www.domain.com/foo-4.5.6.zip'}]
        @mock_actions.stub!(:has_downloads?).and_return(true)
        @mock_actions.stub!(:downloads).and_return(@files)

        Digest::SHA1.stub!(:hexdigest).and_return('generated-hex-digest')
        @checkpoint_file = 'tmp/foo/4.5.6/.checkpoint--download--generated-hex-digest'
      end

      it 'should not define task if package has no downloads' do
        @mock_actions.should_receive(:has_downloads?).and_return(false)
        @pkg.define_download
        Rake::Task.should_not have_defined('foo:4.5.6:download')
      end

      it 'should use download references to define download task' do
        @mock_actions.should_receive(:has_downloads?).and_return(true)
        @mock_actions.should_receive(:downloads).and_return(@files)
        @pkg.define_download
        Rake::Task.should have_defined('foo:4.5.6:download')
      end

      it 'should define file tasks for each downloadable' do
        Rake::Task.should_not have_defined('tmp/foo/4.5.6/foo-4.5.6.zip')
        @pkg.define_download
        Rake::Task.should have_defined('tmp/foo/4.5.6/foo-4.5.6.zip')
      end

      it 'should compute SHA1 digest used in checkpoint file' do
        Digest::SHA1.should_receive(:hexdigest).and_return('generated-hex-digest')
        @pkg.define_download
        Rake::Task.should have_defined(@checkpoint_file)
      end

      it 'should make the checkpoint task dependent on file ones' do
        @pkg.define_download
        Rake::Task[@checkpoint_file].prerequisites.should include('tmp/foo/4.5.6/foo-4.5.6.zip')
      end

      it 'should make checkpoint task part of the download one' do
        @pkg.define_download
        Rake::Task['foo:4.5.6:download'].prerequisites.should include(@checkpoint_file)
      end

      describe '(before actions)' do
        before :each do
          @before_block = Proc.new { }
          @mock_actions.stub!(:before_parts).and_return([@before_block])
        end

        it 'should not define a before-download task when no parts exists' do
          @mock_actions.should_receive(:before_parts).with(:download).and_return(nil)
          @pkg.define_download
          Rake::Task.should_not have_defined('foo:4.5.6:before-download')
        end

        it 'should define a before-download task' do
          @mock_actions.should_receive(:before_parts).with(:download).and_return([@before_blocks])
          @pkg.define_download
          Rake::Task.should have_defined('foo:4.5.6:before-download')
        end

        it 'should make before actions task part of the download task' do
          @pkg.define_download
          Rake::Task['foo:4.5.6:download'].prerequisites.should include('foo:4.5.6:before-download')
        end

        it 'should give before actions task higher priority than main task' do
          @pkg.define_download
          Rake::Task['foo:4.5.6:download'].prerequisites.first.should == 'foo:4.5.6:before-download'
        end

        describe '(persisted)' do
          before :each do
            @mock_actions.stub!(:before_parts).and_return(nil)
            @mock_actions.stub!(:persisted_before_parts).and_return([@before_block])

            @before_checkpoint_file = 'tmp/foo/4.5.6/.checkpoint--before-download--generated-hex-digest'
          end

          it 'should not define before download checkpoint when no parts exists' do
            @mock_actions.should_receive(:persisted_before_parts).with(:download).and_return(nil)
            @pkg.define_download
            Rake::Task.should_not have_defined(@before_checkpoint_file)
          end

          it 'should define a before download checkpoint task' do
            @mock_actions.should_receive(:persisted_before_parts).with(:download).and_return([@before_blocks])
            @pkg.define_download
            Rake::Task.should have_defined(@before_checkpoint_file)
          end

          it 'should compute a SHA1 digest for the actions' do
            Digest::SHA1.should_receive(:hexdigest).with("foo\n4.5.6\nbefore-download\n1")
            @pkg.define_download
          end

          it 'should compute a different SHA1 digest for multiple actions' do
            @mock_actions.stub!(:persisted_before_parts).and_return([@before_block, @before_block])
            Digest::SHA1.should_receive(:hexdigest).with("foo\n4.5.6\nbefore-download\n2")
            @pkg.define_download
          end

          it 'should make before actions checkpoint part of the before-download task' do
            @pkg.define_download
            Rake::Task['foo:4.5.6:before-download'].prerequisites.should include(@before_checkpoint_file)
          end
        end
      end

      describe '(after actions)' do
        before :each do
          @after_block = Proc.new { }
          @mock_actions.stub!(:after_parts).and_return([@after_block])
        end

        it 'should not define after download task when no parts exists' do
          @mock_actions.should_receive(:after_parts).with(:download).and_return(nil)
          @pkg.define_download
          Rake::Task.should_not have_defined('foo:4.5.6:after-download')
        end

        it 'should define after download task' do
          @mock_actions.should_receive(:after_parts).with(:download).and_return([@after_blocks])
          @pkg.define_download
          Rake::Task.should have_defined('foo:4.5.6:after-download')
        end

        it 'should make after actions task part of the download task' do
          @pkg.define_download
          Rake::Task['foo:4.5.6:download'].prerequisites.should include('foo:4.5.6:after-download')
        end

        it 'should give after actions task lower priority than main task' do
          @pkg.define_download
          Rake::Task['foo:4.5.6:download'].prerequisites.last.should == 'foo:4.5.6:after-download'
        end

        describe '(persisted)' do
          before :each do
            @mock_actions.stub!(:after_parts).and_return(nil)
            @mock_actions.stub!(:persisted_after_parts).and_return([@after_block])

            @after_checkpoint_file = 'tmp/foo/4.5.6/.checkpoint--after-download--generated-hex-digest'
          end

          it 'should not define after download checkpoint when no parts exists' do
            @mock_actions.should_receive(:persisted_after_parts).with(:download).and_return(nil)
            @pkg.define_download
            Rake::Task.should_not have_defined(@after_checkpoint_file)
          end

          it 'should define a after download checkpoint task' do
            @mock_actions.should_receive(:persisted_after_parts).with(:download).and_return([@after_blocks])
            @pkg.define_download
            Rake::Task.should have_defined(@after_checkpoint_file)
          end

          it 'should compute a SHA1 digest for the actions' do
            Digest::SHA1.should_receive(:hexdigest).with("foo\n4.5.6\nafter-download\n1")
            @pkg.define_download
          end

          it 'should compute a different SHA1 digest for multiple actions' do
            @mock_actions.stub!(:persisted_after_parts).and_return([@after_block, @after_block])
            Digest::SHA1.should_receive(:hexdigest).with("foo\n4.5.6\nafter-download\n2")
            @pkg.define_download
          end

          it 'should make after actions checkpoint part of the after-download task' do
            @pkg.define_download
            Rake::Task['foo:4.5.6:after-download'].prerequisites.should include(@after_checkpoint_file)
          end
        end
      end
    end

    describe '#define_extract' do
      before :each do
        OneClick.stub!(:sandbox_dir).and_return('tmp')

        @files = [{:file => 'foo-4.5.6.zip'}]
        @mock_actions.stub!(:has_downloads?).and_return(true)
        @mock_actions.stub!(:downloads).and_return(@files)

        Digest::SHA1.stub!(:hexdigest).and_return('generated-hex-digest')
        @checkpoint_file = 'tmp/foo/4.5.6/.checkpoint--extract--generated-hex-digest'
      end

      it 'should not define a task if no downloads are defined' do
        @mock_actions.should_receive(:has_downloads?).and_return(false)
        @pkg.define_extract
        Rake::Task.should_not have_defined('foo:4.5.6:extract')
      end

      it 'should define a task when package contains download intructions' do
        @mock_actions.should_receive(:has_downloads?).and_return(true)
        @pkg.define_extract
        Rake::Task.should have_defined('foo:4.5.6:extract')
      end

      it 'should generate a SHA1 digest using the single file signature' do
        Digest::SHA1.should_receive(:hexdigest).with("tmp/foo/4.5.6/foo-4.5.6.zip")
        @pkg.define_extract
      end

      it 'should generate a SHA1 digest using multiple file signatures' do
        @files << {:file => 'foo-ext-1.2.3.zip'}
        Digest::SHA1.should_receive(:hexdigest).with("tmp/foo/4.5.6/foo-4.5.6.zip\ntmp/foo/4.5.6/foo-ext-1.2.3.zip")
        @pkg.define_extract
      end

      it 'should define a checkpoint file for extraction task' do
        Digest::SHA1.should_receive(:hexdigest).and_return('generated-hex-digest')
        @pkg.define_extract
        Rake::Task.should have_defined(@checkpoint_file)
      end

      it 'should make the checkpoint task dependent on file ones' do
        @pkg.define_extract
        Rake::Task[@checkpoint_file].prerequisites.should include('tmp/foo/4.5.6/foo-4.5.6.zip')
      end

      it 'should make checkpoint task part of the extraction one' do
        @pkg.define_extract
        Rake::Task['foo:4.5.6:extract'].prerequisites.should include(@checkpoint_file)
      end
    end
  end
end

# Task executions
describe OneClick::Package do
  describe '(task execution)' do
    before :each do
      Rake.application.clear

      OneClick.stub!(:sandbox_dir).and_return('sandbox')

      @files = [{:file => 'foo-4.5.6.zip', :url => 'http://www.domain.com/foo-4.5.6.zip'}]
      @mock_actions = mock(OneClick::Package::Actions, :has_downloads? => false)
      @mock_actions.stub!(:before_parts => nil,
                          :after_parts => nil,
                          :persisted_before_parts => nil,
                          :persisted_after_parts => nil)

      @mock_actions.stub!(:has_downloads?).and_return(true)
      @mock_actions.stub!(:downloads).and_return(@files)

      OneClick::Package::Actions.stub!(:new).and_return(@mock_actions)

      @pkg = OneClick::Package.new('foo', '4.5.6')
    end

    describe 'download' do
      before :each do
        @pkg.define_download
      end

      it 'should invoke file download actions' do
        OneClick::Utils.should_receive(:download).with('http://www.domain.com/foo-4.5.6.zip', 'sandbox/foo/4.5.6').once
        Rake::Task['foo:4.5.6:download'].invoke
      end
    end
  end
end
