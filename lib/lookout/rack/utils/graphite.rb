require 'singleton'
require 'configatron'
require 'lookout/statsd'

require 'lookout/rack/utils'

module Lookout::Rack::Utils
  # Statsd proxy.  This class initializes the Statsd client and
  # delegates all stats related calls to it. It uses Lookout's statsd
  # (https://github.com/lookout/statsd) as a wrapper, which can be
  # setup to use another implementation under the hood. Call
  # +Lookout::Statsd.set_instance+ BEFORE referencing the +instance+
  # here in order to use a different Statsd implementation.
  #
  # Use as:
  #   Lookout::Rack::Utils::Graphite.increment('device.associated')
  #   Lookout::Rack::Utils::Graphite.update_counter('device.associated', 5)
  #   Lookout::Rack::Utils::Graphite.timing('device.associated', 3305)
  #   Lookout::Rack::Utils::Graphite.time('device.associated') do
  #     # work
  #   end
  #
  class Graphite
    # Private Constructor -- treat this class like the Singleton it used to be
    def initialize
      if !Lookout::Statsd.instance_set?
        prefix = configatron.statsd.prefix
        unless ENV['RACK_ENV'] == 'production'
          prefix = "dev.#{ENV['USER']}.#{prefix}"
        end

        Lookout::Statsd.create_instance(:host => configatron.statsd.host,
                                        :port => configatron.statsd.port,
                                        :prefix => prefix)
      end
    end

    # Provide same interface as old Singleton, but in test-friendly manner
    def self.instance
      @instance ||= new
    end

    # Clear instance, for use in testing only
    def self.clear_instance
      @instance = nil
    end

    def self.method_missing(meth, *args, &block)
      self.instance && Lookout::Statsd.instance.send(meth, *args, &block)
    end

    def self.respond_to?(method, include_private = false)
      super || (self.instance && Lookout::Statsd.instance.respond_to?(method, include_private))
    end
  end
end
