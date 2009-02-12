#
# Default recipes
#

#
# This defines which compiler and tools will be used as default for the
# following dependencies:
#
#   bootstrap   => all the needed elements to setup the environment
#   compiler    => the compiler that will be used to build all the packages
#   environment => the tools required by the compiler to successfuly work
#

#
# dependency chain:
#
#   environment => compiler => bootstrap
#

task 'bootstrap'    => ['7zip'] # extraction tools
task 'compiler'     => ['gcc3'] # GCC 3 package
task 'environment'  => ['msys'] # MSYS
