set :domain, '52.30.111.249'
current_branch = `git branch`.match(/\* (\S+)\s/m)[1]
set :branch, ENV['branch'] || current_branch || 'master'
