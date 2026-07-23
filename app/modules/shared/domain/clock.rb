module Shared
  # Time source as a port so aggregates and handlers stay deterministic and
  # testable — pass a frozen clock in tests instead of reading Time.now.
  module Clock
    def now
      raise NotImplementedError, "#{self.class} must implement #now"
    end

    # Default production adapter: the real wall clock in UTC.
    class System
      include Clock

      def now
        Time.now.utc
      end
    end
  end
end
