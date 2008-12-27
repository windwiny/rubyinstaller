require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe OneClick::Package::Actions do
  before :each do
    @it = OneClick::Package::Actions.new
  end

  describe '#download' do
    before :each do
      @it.download 'http://www.domain.com/one-file.zip'
    end

    it 'should have downloads' do
      @it.should have_downloads
    end

    it 'should store filename and URL' do
      @it.downloads.first[:file].should == 'one-file.zip'
      @it.downloads.first[:url].should == 'http://www.domain.com/one-file.zip'
    end

    it 'should accept multiple download instructions' do
      @it.download 'http://www.domain.com/another-file.zip'
      @it.should have(2).downloads
    end
  end

  describe '#uses' do
    predicate_matchers[:use] = :uses?

    before :each do
      @it.uses :make
    end

    it 'should use specified tool' do
      @it.should use(:make)
    end

    it 'should accept multiple tools be used' do
      @it.uses :configure
      @it.should use(:make)
      @it.should use(:configure)
    end
  end

  describe '#depends_on' do
    before :each do
      @it.depends_on 'something'
    end

    it 'should have dependencies' do
      @it.should have_dependencies
    end

    it 'should store dependency package name' do
      @it.dependencies.first[:package].should == 'something'
    end

    describe '(versioned)'do
      before :each do
        @it.depends_on 'versioned-package', :version => '1.2.3'
      end

      it 'should store depedency package name' do
        @it.dependencies.last[:package].should == 'versioned-package'
      end

      it 'should store version of depedency package' do
        @it.dependencies.last[:version].should == '1.2.3'
      end
    end
  end
end
