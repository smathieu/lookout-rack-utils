require 'singleton'
require 'configatron'
require 'statsd'

module LookoutRackUtils
  # Statsd proxy.  This class initializes the Statsd client and
  # delegates all stats related calls to it.
  #
  # Use as:
  #   LookoutRackUtils::Graphite.increment('device.associated')
  #   LookoutRackUtils::Graphite.update_counter('device.associated', 5)
  #
  class Graphite
    include Singleton

    def initialize
      prefix = configatron.statsd.prefix
      unless ENV['RACK_ENV'] == 'production'
        prefix = "dev.#{ENV['USER']}.#{prefix}"
      end

      Statsd.create_instance(:host => configatron.statsd.host,
                             :port => configatron.statsd.port,
                             :prefix => prefix)
    end

    def self.method_missing(meth, *args, &block)
      self.instance && Statsd.instance.send(meth, *args)
    end

    def self.respond_to?(method, include_private = false)
      super || (self.instance && Statsd.instance.respond_to?(method, include_private))
    end
  end
end
