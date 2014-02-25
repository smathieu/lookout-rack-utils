require 'spec_helper'
require 'lookout/rack/utils/log'
require 'timecop'
require 'configatron'

describe Lookout::Rack::Utils::Log do
  subject(:log) { described_class.instance }

  before :all do
    configatron.logging.enabled = true
    configatron.logging.file = "log"
  end

  describe '.debug' do
    context 'if debug is in configatron.statsd.exclude_levels' do
      before { configatron.statsd.exclude_levels = [:debug] }
      after { configatron.statsd.exclude_levels = [] }

      it 'should not log a graphite stat' do
        Lookout::Rack::Utils::Graphite.should_not_receive(:increment).with('log.debug')
        log.debug 'foo'
      end
    end

    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.debug')
      log.debug 'foo'
    end
  end

  describe '.debug' do
    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.debug')
      log.debug 'foo'
    end
  end

  describe '.info' do
    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.info')
      log.info 'foo'
    end
  end

  describe '.warn' do
    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.warn')
      log.warn 'foo'
    end
  end

  describe '.error' do
    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.error')
      log.error 'foo'
    end
  end

  describe '.fatal' do
    it 'should log a graphite stat' do
      Lookout::Rack::Utils::Graphite.should_receive(:increment).with('log.fatal')
      log.fatal 'foo'
    end
  end

  describe '.debug?' do
    it 'returns true when level is debug' do
      expect(log.debug?).to eq(true)
    end
  end

  describe '.info?' do
    it 'returns true when level is info' do
      expect(log.info?).to eq(true)
    end
  end

  describe '.warn?' do
    it 'returns true when level is warn' do
      expect(log.warn?).to eq(true)
    end
  end

  describe '.error?' do
    it 'returns true when level is error' do
      expect(log.error?).to eq(true)
    end
  end

  describe '.fatal?' do
    it 'returns true when level is fatal' do
      expect(log.fatal?).to eq(true)
    end
  end
end

describe Lookout::Rack::Utils::Log::LookoutFormatter do
  subject(:formatter) { described_class.new }
  let(:logger) do
    logger = double('Mock Logger')
    logger.stub(:name).and_return('RSpec Logger')
    logger.stub(:fullname).and_return('RSpec Logger')
    logger
  end
  let(:project_name) { 'some_project' }
  let(:basedir) { "/home/rspec/#{project_name}" }
  let(:tracer) do
    [
      "#{basedir}/log.rb:63:in `warn'",
      "#{basedir}/spec/log_spec.rb:9:in `block (2 levels) in <top (required)>'"
    ]
  end

  before :all do
    # The root logger creates the log levels, so making sure it's been
    # created
    Log4r::RootLogger.instance
  end


  before :each do
    formatter.stub(:basedir).and_return(basedir)
  end


  describe '#event_filename' do
    subject(:filename) { formatter.event_filename(tracer[1]) }

    context 'with a normal MRI LogEvent' do
      it { should eql('spec/log_spec.rb:9') }
    end

    # We have slightly different log formats under packaged .jar files
    context 'with a LogEvent from a packaged .jar' do
      let(:tracer) { [nil, "backend/metrics.rb:52:in `runloop'"] }
      let(:basedir) { 'file:/home/user/source/projects/stuff.jar!/project' }

      it { should eql('backend/metrics.rb:52') }
    end
  end

  describe '#format' do
    before :each do
      Timecop.freeze
    end

    after :each do
      Timecop.return
    end

    context 'with a valid LogEvent' do
      # Level 3 is the Log4r "warn" level
      let(:level) { 3 }
      let(:data) { 'rspec' }
      let(:timestamp) { Time.now.utc.iso8601 }

      let(:event) do
        event = Log4r::LogEvent.new(level, logger, tracer, data)
      end

      it 'should be properly formatted' do
        expect(formatter.format(event)).to eql("WARN: #{timestamp}: spec/log_spec.rb:9: #{data}\n")
      end
    end

  end
end
