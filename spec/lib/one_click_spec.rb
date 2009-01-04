require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OneClick do
  describe '#root_path' do
    it 'should be absolute to the source location' do
      root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      OneClick.root_path.should == root
    end
  end

  describe '#sandbox_dir' do
    it 'should default to sandbox' do
      OneClick.sandbox_dir.should == 'sandbox'
    end
  end

  describe '#tmp_dir' do
    it 'should default to tmp' do
      OneClick.tmp_dir.should == 'tmp'
    end
  end
end
