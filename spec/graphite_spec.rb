require 'spec_helper'
require 'lookout_rack_utils/graphite'

describe LookoutRackUtils::Graphite do
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
    LookoutRackUtils::Graphite.increment('device.associated')
  end
end
