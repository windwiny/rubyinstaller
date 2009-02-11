require 'rake'
require 'ostruct'

module OneClick
  autoload :Package, 'one_click/package'
  autoload :Utils, 'one_click/utils'

  def self.root_path
    @root_path ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def self.sandbox_dir
    @sandbox_dir ||= 'sandbox'
  end

  def self.tmp_dir
    @tmp_dir ||= 'tmp'
  end

  def self.options
    @options ||= OpenStruct.new
  end
end
