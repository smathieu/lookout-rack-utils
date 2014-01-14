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
end
