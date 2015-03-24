set :application, "theodlite"
set :repository,  "https://github.com/errorstudio/theodolite.git"

set :stages, %w(live staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# bundler setup
set :bundle_dir, ''
set :bundle_flags, '--system --quiet'
set :bundle_without, [:darwin, :development, :test]
require 'bundler/capistrano'

# RVM setup
set(:rvm_ruby_string) {"ruby-2.1.4@#{application}-#{stage}"}
set :rvm_type, :system
set :rvm_install_with_sudo, true
set :rvm_install_ruby, :install
require 'rvm/capistrano'

set(:deploy_to)         { "/var/www/#{primary_domain}" }
set(:releases_path)     { File.join(deploy_to, version_dir) }
set(:shared_path)       { File.join(deploy_to, shared_dir) }
set(:current_path)      { File.join(deploy_to, current_dir) }
set(:release_path)      { File.join(releases_path, release_name) }


#folders / files which need to be shared across deploys
set :shared_files, %w()

set :scm, :git
set :deploy_via, :remote_cache
set :normalize_asset_timestamps, false

set :use_sudo, false
set :user, "deployment"
ssh_options[:forward_agent] = true

set :use_private_mysql_ip, true

load 'config/capistrano_recipes/nginx/generate_config'
load 'config/capistrano_recipes/ruby/rvm'
load 'config/capistrano_recipes/rails/symlinks'
load 'config/capistrano_recipes/passenger_server/passenger'

# Custom cap tasks - taken from rails/base
set :requires_passenger, true
after "deploy:setup",'nginx:generate_config'
after 'deploy:cold',"passenger:restart"
after "deploy", "rails:update_shared_symlinks", "deploy:set_ownership","passenger:restart"

after "deploy:setup", "deploy:cold"
after "passenger:restart", "deploy:set_ownership"
