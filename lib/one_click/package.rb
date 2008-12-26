module OneClick
  class Package
    attr_accessor :name
    attr_accessor :version

    def initialize(name = nil, version = nil, &block)
      @name = name
      @version = version
      define if block_given?
    end

    def define
      fail 'package name is required' if @name.nil?
      fail 'package version is required' if @version.nil?
    end
  end
end
