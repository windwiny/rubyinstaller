require 'rake/clean'

# temporary files should be removed during clean task
CLEAN.include(OneClick.tmp_dir)

# clobbering should remove sandboxed environment
CLOBBER.include(OneClick.sandbox_dir)
