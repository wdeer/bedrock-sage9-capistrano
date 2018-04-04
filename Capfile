# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes Git SCM plugin
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Load Composer
require 'capistrano/composer'

# Load wp-cli
require 'capistrano/wpcli'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
# Customize this path to change the location of your custom tasks.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
