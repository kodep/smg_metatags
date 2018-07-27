require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/multistage'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

#set :domain, 'foobar.com'
set :deploy_to, '/home/ubuntu/smg_metatags'
set :repository, 'git@github.com:kodep/smg_metatags.git'
#set :branch, 'master'

# For system-wide RVM install.
set :rvm_path, '/home/ubuntu/.rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [ 'log']

# Optional settings:
set :user, 'ubuntu'    # Username in the server to SSH to.
set :port, '22'     # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
	invoke :'rvm:use[ruby-2.3.0]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]
  if repository
    repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
    repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'

    queue %[
      if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
        ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
      fi
    ]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'eye:stop'

    to :launch do
      invoke :'eye:start'
    end
  end
end
namespace :eye do
  desc "start eye for eye"
  task :start => :environment do
    queue %[echo "-----> Start Eye"]
    queue %{
    echo "Eye starting in #{rails_env}"
    cd "#{deploy_to}/#{current_path}"
    #{echo_cmd %[bundle exec eye l metatag.eye] }
    }
    queue %{cd "#{deploy_to}/#{current_path}"; sleep 10; bundle exec eye i}
  end
  desc "stop eye for sidekiq"
  task :stop => :environment do
    queue %[echo "-----> Stop Eye"]
    queue %{echo "Eye stop in #{rails_env}"}
    queue %{cd "#{deploy_to}/#{current_path}"
    #{echo_cmd %[bundle exec eye q -s > /dev/null 2>&1; true] }
  }
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
