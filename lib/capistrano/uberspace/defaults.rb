set :ssh_options, { forward_agent: true }
set :pty, true
set :deploy_to, -> { "/var/www/virtual/#{fetch :user}/apps/#{fetch :application}" }
set :deploy_via, :remote_cache
set :use_sudo, false

set :bundle_path, -> { '~/.gem' }
set :bundle_flags, ''

set :domain, nil
set :add_www_domain, -> { !!fetch(:domain) }
set :passenger_environment, -> { fetch(:rails_env) || fetch(:stage) }

set :uberspace_roles, :all
set :extra_env_variables, fetch(:extra_env_variables) || {}

set :uberspace_env_variables, -> {
  {
    'PATH' => "/package/host/localhost/ruby-2.2/bin:#{uberspace_home}/.gem/ruby/2.2.0/bin:$PATH"
  }.merge(fetch :extra_env_variables)
}

%w(mysql postgresql sqlite3).each do |db|
  if Rake.application.tasks.collect(&:to_s).include?("uberspace:setup_#{db}")
    before :'uberspace:check', "uberspace:setup_#{db}"
  end
end

set :linked_dirs,  fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
