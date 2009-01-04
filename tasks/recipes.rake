# This rake task file loads the recipes (recipes/**/*.rake)

# add lib directory to the search path
libdir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'one_click'

# load recipes rakefiles
Dir['recipes/**/*.rake'].sort.each { |f| load f }
