load File.expand_path('../../tasks/uberspace/puma.rake', __FILE__)

module Capistrano
  module Uberspace
    module Puma
      def self.start_server_command(port:, environment:, **_options)
        "exec bundle exec rails server --port #{port} -e #{environment} 2>&1"
      end
    end

    self.server_module = Puma
  end
end
