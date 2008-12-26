require 'rake/clean'

# common pattern cleanup
CLEAN.include('tmp')

# run specs by default
task :default => [:spec]
