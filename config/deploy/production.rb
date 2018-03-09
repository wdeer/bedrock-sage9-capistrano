set :stage, :production
# set :branch, :otherBranch

server fetch(:server), user: fetch(:user), roles: %w{web app db}

set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: true
}

fetch(:default_env).merge!(wp_env: :production)
