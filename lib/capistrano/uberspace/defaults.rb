set :ssh_options, { forward_agent: true }
set :pty, true
set :deploy_to, -> { "/var/www/virtual/#{fetch :user}/apps/#{fetch :application}" }
set :deploy_via, :remote_cache
set :use_sudo, false

# set :bundle_path, -> { '~/.gem' }
set :bundle_flags, '--deployment'

set :domain, nil
set :add_www_domain, -> { !!fetch(:domain) }
set :passenger_environment, -> { fetch(:rails_env) || fetch(:stage) }

set :uberspace_roles, :all
set :extra_env_variables, fetch(:extra_env_variables) || {}

set :ruby_version, fetch(:ruby_version, '2.2.3')

set :gem_path, (lambda do
  begin
    gempath = ''
    on roles(:all) do
      gempath = capture "PATH=#{fetch :ruby_path}:$PATH ruby -e 'require \"rubygems\"; print Gem.user_dir'"
    end
    @gempath = "#{gempath}/bin"
  end unless @gempath
  @gempath
end)

set :ruby_path, -> { "/package/host/localhost/ruby-#{fetch :ruby_version}/bin" }

set :uberspace_env_variables, lambda {
  {
    'PATH' => "#{fetch :ruby_path}:#{fetch :gem_path}:/home/#{fetch :user}/bin:$PATH"
  }.merge(fetch :extra_env_variables)
}

default_env = fetch(:default_env, {})
set :default_env, -> { default_env.merge(fetch(:uberspace_env_variables)) }

set :linked_dirs,  fetch(:linked_dirs, []).push(*%w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads))
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# default is "set :bundle_bins, %w{gem rake rails}", but we want to 'gem install bundler' without bundle :)
set :bundle_bins, %w(rake rails)
