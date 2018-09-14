# encoding: UTF-8

require 'prometheus/client'
require 'prometheus/client/summary'
require 'examples/metric_example'

describe Prometheus::Client::Summary do
  # Reset the data store
  before do
    Prometheus::Client.config.data_store = Prometheus::Client::DataStores::Synchronized.new
  end

  let(:summary) { Prometheus::Client::Summary.new(:bar, 'bar description') }

  it_behaves_like Prometheus::Client::Metric do
    let(:type) { Hash }
  end

  describe '#observe' do
    it 'records the given value' do
      expect do
        summary.observe({}, 5)
      end.to change { summary.get }.
        from({ "count" => 0.0, "sum" => 0.0 }).
        to({ "count" => 1.0, "sum" => 5.0 })
    end

    it 'raise error for quantile labels' do
      expect do
        summary.observe({ quantile: 1 }, 5)
      end.to raise_error Prometheus::Client::LabelSetValidator::ReservedLabelError
    end
  end

  describe '#get' do
    before do
      summary.observe({ foo: 'bar' }, 3)
      summary.observe({ foo: 'bar' }, 5.2)
      summary.observe({ foo: 'bar' }, 13)
      summary.observe({ foo: 'bar' }, 4)
    end

    it 'returns a value which responds to #sum and #total' do
      summary.get(foo: 'bar').
        to eql({ "count" => 4.0, "sum" => 25.2 })
    end
  end

  describe '#values' do
    it 'returns a hash of all recorded summaries' do
      summary.observe({ status: 'bar' }, 3)
      summary.observe({ status: 'foo' }, 5)

      expect(summary.values).to eql(
        { status: 'bar' } => { "count" => 1.0, "sum" => 3.0 },
        { status: 'foo' } => { "count" => 1.0, "sum" => 5.0 },
      )
    end
  end
end
