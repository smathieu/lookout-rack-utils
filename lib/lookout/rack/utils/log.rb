require 'rubygems'
require 'singleton'
require 'time'
require 'configatron'

module Lookout::Rack::Utils
  class Log
    include Singleton

    def initialize
      file = configatron.logging.file

      if configatron.logging.enabled
        @logger = if file == 'stdout'
          Logger.new($stdout)
        else
          Logger.new(file)
        end
      else
        @logger = Logger.new(File::NULL)
      end

      @logger.level = Logger.const_get(configatron.logging.level)
    end

    [:debug, :info, :warn, :error, :fatal, :level].each do |method|
      define_method(method) do |*args, &block|
        if defined?(Lookout::Rack::Utils::Graphite)
          unless method == :level
            unless (configatron.statsd.exclude_levels || []).include?(method)
              Lookout::Rack::Utils::Graphite.increment("log.#{method}")
            end
          end
        end
        @logger.send(method, *args, &block)
      end
    end

    def method_missing(name, *args, &block)
      @logger.public_send(name, *args, &block)
    end
  end
end
