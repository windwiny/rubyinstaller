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

  describe '#before' do
    it 'should collect before parts for action' do
      @it.before_parts(:download).should be_nil
      @it.before(:download) { }
      @it.before_parts(:download).should_not be_nil
    end

    it 'should allow collection of parts for different actions' do
      @it.before(:download) { }
      @it.before(:extract) { }
      @it.should have(1).before_parts(:download)
      @it.should have(1).before_parts(:extract)
    end

    it 'should allow collection of multiple parts for same action' do
      2.times { @it.before(:download) { } }
      @it.should have(2).before_parts(:download)
    end
  end

  describe '#before(:persist => true)' do
    it 'should collect persistable before parts for action' do
      @it.persisted_before_parts(:install).should be_nil
      @it.before(:install, :persist => true) { }
      @it.persisted_before_parts(:install).should_not be_nil
    end
  end

  describe '#after' do
    it 'should collect after parts for action' do
      @it.after_parts(:download).should be_nil
      @it.after(:download) { }
      @it.after_parts(:download).should_not be_nil
    end

    it 'should allow collection of parts for different actions' do
      @it.after(:download) { }
      @it.after(:extract) { }
      @it.should have(1).after_parts(:download)
      @it.should have(1).after_parts(:extract)
    end

    it 'should allow collection of multiple parts for same action' do
      2.times { @it.after(:download) { } }
      @it.should have(2).after_parts(:download)
    end
  end

  describe '#after(:persist => true)' do
    it 'should collect persistable after parts for action' do
      @it.persisted_after_parts(:install).should be_nil
      @it.after(:install, :persist => true) { }
      @it.persisted_after_parts(:install).should_not be_nil
    end
  end

  describe '#depends_on' do
    it 'should not contain any dependency when initialized' do
      @it.should_not have_dependencies
    end

    it 'should allow collection of dependencies' do
      @it.should have(0).dependencies
      @it.depends_on 'foo'
      @it.depends_on 'bar'
      @it.should have(2).dependencies
    end

    it 'should only allow one dependency to be added' do
      @it.depends_on 'foo'
      @it.depends_on 'foo'
      @it.should have(1).dependencies
    end

    it 'should keep dependencies in the specified order' do
      @it.depends_on 'foo'
      @it.depends_on 'bar'
      @it.dependencies.first.should == 'foo'
      @it.dependencies.last.should == 'bar'
    end
  end
end
