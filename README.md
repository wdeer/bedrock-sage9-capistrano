# Capistrano deploy configs

### These configs have been costomized for use with a root's [Sage9](https://github.com/roots/sage) based theme utilizing root's [Bedrock](https://github.com/roots/bedrock) 

## What it does
* Runs `npm run build:production` in sage9 theme directory to generate **dist/** directory
* Uploads **dist/** directory to remote server and places in theme directory
* Runs `composer install` within sage9 theme directory to install required libs
* Has custom path for `composer` command to point to non-default server php and/or composer path


## Getting Started

### Merge the following files into your existing bedrock project root directory:

* ./config/deploy.rb
* ./config/deploy/production.rb
* ./config/deploy/staging.rb

### Then, update the following in **deploy.rb**:

* `set :application, 'projectname.com'` **## Project name, usually domain**
* `set :user, 'username'` **## Username for account on remote host**
* `set :server, 'XXX.XXX.XX.XX'` **## Remote Server IP**
* `set :repo_url, 'git@github.com:GITUSERNAME/GITPROJECTNAME.GIT'` **## Path to master repo**
* `set :theme_dir, 'THEME_DIR'` **## Theme directory name**


### Optionally, update the following, also in **deploy.rb**:
* `set :webroot, 'web'` **## Path to server's webroot if different from bedrock's default of 'web'**
* `set :branch, :master` **## Sets default repo branch you can override in individual ./config/deploy/##stage##.rb )**
* `set :keep_releases, 10` **## Number of releases to keep for rollbacks**
* `set :log_level, :info` **## Change to 'debug' if you need more info output in cli**
* `SSHKit.config.command_map[:composer] = "/opt/cpanel/ea-php70/root/usr/bin/php /usr/local/bin/composer"` **## Maps composer command to custom PHP path / full composer path. Remove/Adjust if un/needed**


### Lastly, Run the following (general capistrano stuff)
**note:** you should **stage/commit all necessary changes** and **push to remote repo prior to running each deploy**, otherwise they wont show up on the remote server

* `cap staging deploy:check` and fix any errors
* Once errors are fixed try to deploy by running: `cap staging deploy`
* Then once you're really ready ready deploy to production: `cap production deploy`


# Hopefully all went well ...CHEERS!
:beers: