set :application, 'projectname.com' ## Project name, usually domain
set :user, 'username' ## Username for account on remote host
set :server, 'XXX.XXX.XX.XX' ## Remote Server IP
set :repo_url, 'git@github.com:username/projectname.com.git' ## Path to master repo

## Name of webroot directory for project (for example 'public_html', 'web', 'public', 'www' etc)
set :webroot, 'web'

## Name of theme directory
set :theme_dir, 'play-miamisburg'

## Sets default repo branch ( you can override in individual ./config/deploy/##stage##.rb )
set :branch, :master

## number of releases to keep for rollbacks
## run command: "cap <stage> deploy:rollback" when you goof up
set :keep_releases, 10

## Verbosity in capistrano's cli output
## change to 'debug' if you need more info output
set :log_level, :info

## Maps composer command to custom PHP path / full composer path
## Remove/Adjust if un/needed
SSHKit.config.command_map[:composer] = "/opt/cpanel/ea-php70/root/usr/bin/php /usr/local/bin/composer"




####################################################
## You shouldn't need to edit anything below here ##
####################################################

## Location to dump temporary files
set :tmp_dir, "/home/#{fetch(:user)}/.tmp"

set :scm_verbose, "true"
set :deploy_via, :copy
set :pty, false


## Symlinks files/dirs that are shared across all releases
set :linked_files, fetch(:linked_files, []).push( '.env', fetch(:webroot) + '/.htaccess' )
set :linked_dirs, fetch(:linked_dirs, []).push( fetch(:webroot) + '/app/uploads' )




## The following runs production build to generate /dist/ directory
## then uploads it to the current release's theme directory
namespace :deploy do
  set :local_app_path, Pathname.new(Dir.pwd)
  set :local_theme_path, fetch(:local_app_path).join(fetch(:webroot), 'app/themes/', fetch(:theme_dir))
  set :local_dist_path, fetch(:local_theme_path).join('dist')

  task :compile do
    run_locally do
      within fetch(:local_theme_path) do
        execute :npm, 'run build:production'
      end
    end
  end

  task :copy do
    on roles(:web) do
      set :theme_path, fetch(:release_path).join(fetch(:webroot),'app/themes/',fetch(:theme_dir))
      set :remote_dist_path, -> { release_path.join(fetch(:theme_path)).join('dist') }

      puts "Your local distribution path: #{fetch(:local_dist_path)} "
      puts "Your remote distribution path: #{fetch(:remote_dist_path)} "
      puts "Uploading files to remote "
      upload! fetch(:local_dist_path).to_s, fetch(:remote_dist_path), recursive: true
    end
  end

  task assets: %w(compile copy)

end
####

## The following uploads dist directory to curren release's theme directory
namespace :deploy do

  task :copyonly do
    on roles(:web) do
      set :theme_path, fetch(:release_path).join(fetch(:webroot),'app/themes/',fetch(:theme_dir))
      set :remote_dist_path, -> { release_path.join(fetch(:theme_path)) }
      puts "Your local distribution path: #{fetch(:local_dist_path)} "
      puts "Your remote distribution path: #{fetch(:remote_dist_path)} "
      puts "Uploading files to remote "
      upload! fetch(:local_dist_path).to_s, fetch(:remote_dist_path), recursive: true
    end
  end

  task assetsonly: %w(deploy:compile copyonly)

end
## Runs the previous block before the deploy is updated
after 'deploy:updated', 'deploy:assets'
####



## The following runs "composer install" within theme directory pointing to php70 binary
## The stylesheet and template roots are also updated (REQUIRES WP-CLI on server)
namespace :deploy do
  desc 'Update WordPress template root paths to point to the new release'
  task :update_option_paths do
    on roles(:app) do

## COMMENT OUT the next 4 lines if composer is not needed within the theme
      set :theme_path, fetch(:release_path).join(fetch(:webroot),'app/themes/',fetch(:theme_dir))
      within fetch(:theme_path) do
        execute :composer, :install
      end
#########

      within fetch(:release_path) do
        if test :wp, :core, 'is-installed'
          [:stylesheet_root, :template_root].each do |option|
            # Only change the value if it's an absolute path
            # i.e. The relative path "/themes" must remain unchanged
            # Also, the option might not be set, in which case we leave it like that
            value = capture :wp, :option, :get, option, raise_on_non_zero_exit: false
            if value != '' && value != '/themes'
              execute :wp, :option, :set, option, fetch(:release_path).join( fetch(:webroot) + '/wp/wp-content/themes')
            end
          end
        end
      end

    end
  end
end
## Runs the previous block after publishing
after 'deploy:publishing', 'deploy:update_option_paths'


## The task below is not run by default
## uncomment "after 'deploy:publishing', 'deploy:restart'" if needed
namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :service, :apache, :reload
    end
  end
end
# after 'deploy:publishing', 'deploy:restart'
