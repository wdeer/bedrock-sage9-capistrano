set :stage, :staging
# set :branch, :otherBranch

set :deploy_to, -> { "/home/#{fetch(:user)}/staging.#{fetch(:application)}" }

server fetch(:server), user: fetch(:user), roles: %w{web app db}

set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true
}

fetch(:default_env).merge!(wp_env: :staging)
