require 'sshkit/backends/connection_pool'

module SSHKit
  module Backend
    class ConnectionPool
      def close_all_connections
        @mutex.synchronize do
          @pool.values.each do |entries|
            entries.each do |entry|
              entry.connection.close if entry.connection.respond_to?(:close) && !entry.closed?
            end
          end
        end
        flush_connections
      end
    end
  end
end
