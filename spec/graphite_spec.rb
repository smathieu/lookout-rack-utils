require 'spec_helper'
require 'lookout/rack/utils/graphite'

describe Lookout::Rack::Utils::Graphite do
  subject(:graphite) { described_class }

  before :each do
    graphite.instance # Initialize statsd singleton
    configatron.statsd.stub(:prefix).and_return('test')
  end

  context 'offers statsd methods' do
    it { should respond_to :increment }
    it { should respond_to :decrement }
    it { should respond_to :timing }
    it { should respond_to :update_counter }
  end

  it 'should delegate to statsd' do
    Statsd.instance.should_receive(:increment).once.with('device.associated')
    Lookout::Rack::Utils::Graphite.increment('device.associated')
  end

  describe '#timing' do
    it 'should delegate the block to statsd' do
      expect { |block|
        Statsd.instance.should_receive(:timing).once.with('device.became_aware', &block)
        Lookout::Rack::Utils::Graphite.timing('device.became_aware', &block)
      }.to yield_control
    end

    it 'should delegate the sample rate and block to statsd' do
      expect { |block|
        Statsd.instance.should_receive(:timing).once.with('device.became_aware', 0.05, &block)
        Lookout::Rack::Utils::Graphite.timing('device.became_aware', 0.05, &block)
      }.to yield_control
    end
  end
end
