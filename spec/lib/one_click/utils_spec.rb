require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# OneClick Utilities (download, extraction, etc)
describe OneClick::Utils do
  describe '#download' do
    before :each do
      @mocked_uri = mock(URI)
      @mocked_uri.stub!(:download)

      URI.stub!(:parse).and_return(@mocked_uri)
    end

    it 'should parse resource URL' do
      URI.should_receive(:parse).
        with('http://www.domain.com/foo-4.5.6.zip').and_return(@mocked_uri)

      OneClick::Utils.download('http://www.domain.com/foo-4.5.6.zip',
                                'sandbox/foo/4.5.6')
    end

    it 'should proceed to download into indicated target' do
      @mocked_uri.should_receive(:download).
        with('sandbox/foo/4.5.6/foo-4.5.6.zip', anything)

      OneClick::Utils.download('http://www.domain.com/foo-4.5.6.zip',
                                'sandbox/foo/4.5.6')
    end

    it 'should provide a temporary folder using default one' do
      OneClick.stub!(:tmp_dir).and_return('temp')
      @mocked_uri.should_receive(:download).
        with(anything, hash_including(:tmp_dir => 'temp'))

      OneClick::Utils.download('http://www.domain.com/foo-4.5.6.zip',
                                'sandbox/foo/4.5.6')
    end
  end
end
