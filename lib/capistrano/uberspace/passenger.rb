load File.expand_path('../../tasks/uberspace/passenger.rake', __FILE__)

module Capistrano
  module Uberspace
    module Passenger
      def self.start_server_command(port:, environment:, **_options)
        "exec bundle exec passenger start -p #{port} -e #{environment} 2>&1"
      end
    end

    self.server_module = Passenger
  end
end
