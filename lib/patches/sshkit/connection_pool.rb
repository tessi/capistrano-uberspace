require 'sshkit/backends/connection_pool'

module SSHKit
  module Backend
    class ConnectionPool
      def close_all_connections
        close_connections
        flush_connections
      end
    end
  end
end
