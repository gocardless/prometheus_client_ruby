# encoding: UTF-8

require 'prometheus/client'
require 'prometheus/client/gauge'
require 'examples/metric_example'

describe Prometheus::Client::Gauge do
  # Reset the data store
  before do
    Prometheus::Client.config.data_store = Prometheus::Client::DataStores::Synchronized.new
  end

  let(:gauge) { Prometheus::Client::Gauge.new(:foo, 'foo description') }

  it_behaves_like Prometheus::Client::Metric do
    let(:type) { Float }
  end

  describe '#set' do
    it 'sets a metric value' do
      expect do
        gauge.set({}, 42)
      end.to change { gauge.get }.from(0).to(42)
    end

    it 'sets a metric value for a given label set' do
      expect do
        expect do
          gauge.set({ test: 'value' }, 42)
        end.to change { gauge.get(test: 'value') }.from(nil).to(42)
      end.to_not change { gauge.get(test: 'foo') }
    end

    context 'given an invalid value' do
      it 'raises an ArgumentError' do
        expect do
          gauge.set({}, nil)
        end.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#increment' do
    before do
      gauge.set(RSpec.current_example.metadata[:labels] || {}, 0)
    end

    it 'increments the gauge' do
      expect do
        gauge.increment
      end.to change { gauge.get }.by(1.0)
    end

    it 'increments the gauge for a given label set', labels: { test: 'one' } do
      expect do
        expect do
          gauge.increment(test: 'one')
        end.to change { gauge.get(test: 'one') }.by(1.0)
      end.to_not change { gauge.get(test: 'another') }
    end

    it 'increments the gauge by a given value' do
      expect do
        gauge.increment({}, 5)
      end.to change { gauge.get }.by(5.0)
    end

    it 'returns the new gauge value' do
      expect(gauge.increment).to eql(1.0)
    end

    it 'is thread safe' do
      expect do
        Array.new(10) do
          Thread.new do
            10.times { gauge.increment }
          end
        end.each(&:join)
      end.to change { gauge.get }.by(100.0)
    end
  end

  describe '#decrement' do
    before do
      gauge.set(RSpec.current_example.metadata[:labels] || {}, 0)
    end

    it 'decrements the gauge' do
      expect do
        gauge.decrement
      end.to change { gauge.get }.by(-1.0)
    end

    it 'decrements the gauge for a given label set', labels: { test: 'one' } do
      expect do
        expect do
          gauge.decrement(test: 'one')
        end.to change { gauge.get(test: 'one') }.by(-1.0)
      end.to_not change { gauge.get(test: 'another') }
    end

    it 'decrements the gauge by a given value' do
      expect do
        gauge.decrement({}, 5)
      end.to change { gauge.get }.by(-5.0)
    end

    it 'returns the new gauge value' do
      expect(gauge.decrement).to eql(-1.0)
    end

    it 'is thread safe' do
      expect do
        Array.new(10) do
          Thread.new do
            10.times { gauge.decrement }
          end
        end.each(&:join)
      end.to change { gauge.get }.by(-100.0)
    end
  end
end
