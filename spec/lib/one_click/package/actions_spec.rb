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
end
