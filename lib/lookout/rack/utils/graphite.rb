require 'singleton'
require 'configatron'
require 'statsd'

require 'lookout/rack/utils'

module Lookout::Rack::Utils
  # Statsd proxy.  This class initializes the Statsd client and
  # delegates all stats related calls to it.
  #
  # Use as:
  #   Lookout::Rack::Utils::Graphite.increment('device.associated')
  #   Lookout::Rack::Utils::Graphite.update_counter('device.associated', 5)
  #   Lookout::Rack::Utils::Graphite.timing('device.associated') do
  #     # work
  #   end
  #
  class Graphite
    include Singleton

    def initialize
      prefix = configatron.statsd.prefix
      unless ENV['RACK_ENV'] == 'production'
        prefix = "dev.#{ENV['USER']}.#{prefix}"
      end

      ::Statsd.create_instance(:host => configatron.statsd.host,
                               :port => configatron.statsd.port,
                               :prefix => prefix)
    end

    def self.method_missing(meth, *args, &block)
      self.instance && ::Statsd.instance.send(meth, *args, &block)
    end

    def self.respond_to?(method, include_private = false)
      super || (self.instance && ::Statsd.instance.respond_to?(method, include_private))
    end
  end
end
