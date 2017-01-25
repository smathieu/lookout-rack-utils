require 'spec_helper'
require 'lookout/rack/utils/log'
require 'timecop'
require 'configatron'

describe Lookout::Rack::Utils::Log do
  subject(:log) { described_class.instance }
  subject(:log_message) { 'foo' }
  let(:filename) { "log" }

  before :each do
    configatron.logging.enabled = true
    configatron.logging.level = "DEBUG"
    allow(configatron.logging).to receive(:file).and_return(filename)
  end

  describe '.debug' do
    context 'if debug is in configatron.statsd.exclude_levels' do
      before { configatron.statsd.exclude_levels = [:debug] }
      after { configatron.statsd.exclude_levels = [] }

      it 'should not log a graphite stat' do
        Lookout::Rack::Utils::Graphite.should_not_receive(:increment).with('log.debug')
        log.debug log_message
      end
    end

    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.debug')
      log.debug log_message
    end

    context "with logging disabled" do
      before :each do
        configatron.logging.enabled = false
      end

      it "should not log anything" do
        log.debug log_message
        # kinda hard to test, but provides code coverage
      end
    end
  end

  [:debug, :info, :warn, :error, :fatal].each do |method|
    describe ".#{method}" do
      it 'should log a graphite stat' do
        Lookout::Rack::Utils::Graphite.should_receive(:increment).with("log.#{method}")

        log.instance_variable_get(:@logger).should_receive(method).with(log_message).and_call_original

        processed = false
        b = Proc.new { processed = true }

        log.send(method, log_message, &b)
        expect(processed).to be(true)
      end

      it 'should invoke the internal logger object with a given block' do
        log.instance_variable_get(:@logger).should_receive(method).with(log_message).and_call_original
        processed = false
        b = Proc.new { processed = true }
        log.send(method, log_message, &b)
        expect(processed).to be(true)
      end

      it 'should invoke the internal logger object w/o a given block' do
        log.instance_variable_get(:@logger).should_receive(method).with(log_message).and_call_original
        log.send(method, log_message)
      end
    end
  end

  [:debug?, :info?, :warn?, :error?, :fatal?].each do |method|
    describe ".#{method}" do
      it 'returns true when level is debug' do
        expect(log.send(method)).to eq(true)
      end
    end
  end
end

