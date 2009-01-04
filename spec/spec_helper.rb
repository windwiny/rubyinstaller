# add lib directory to the search path
libdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'spec'

require 'one_click'

Spec::Runner.configure do |config|
  config.predicate_matchers[:have_defined] = :task_defined?
end
