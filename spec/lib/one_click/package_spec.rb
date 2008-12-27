require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
      @mock_actions = mock(OneClick::Package::Actions)
      OneClick::Package::Actions.stub!(:new).and_return(@mock_actions)
      @a_block = proc { }
    end

    it 'should create an actions instance if a block was provided' do
      OneClick::Package::Actions.should_receive(:new)
      OneClick::Package.new('foo', '1.2.3') { }
    end

    it 'should delegate block to actions instance' do
      @mock_actions.should_receive(:instance_eval).with(&@a_block)
      OneClick::Package.new('foo', '1.2.3', &@a_block)
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
end
