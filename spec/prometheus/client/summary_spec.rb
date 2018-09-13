# encoding: UTF-8

require 'prometheus/client/summary'
require 'examples/metric_example'

describe Prometheus::Client::Summary do
  let(:summary) { Prometheus::Client::Summary.new(:bar, 'bar description') }

  it_behaves_like Prometheus::Client::Metric do
    let(:type) { Prometheus::Client::Summary::Value }
  end

  describe '#observe' do
    it 'records the given value' do
      expect do
        expect do
          summary.observe({}, 5)
        end.to change { summary.get.sum }.from(0.0).to(5.0)
      end.to change { summary.get.total }.from(0.0).to(1.0)
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
      value = summary.get(foo: 'bar')

      expect(value.sum).to eql(25.2)
      expect(value.total).to eql(4.0)
    end
  end

  describe '#values' do
    it 'returns a hash of all recorded summaries' do
      summary.observe({ status: 'bar' }, 3)
      summary.observe({ status: 'foo' }, 5)

      expect(summary.values[{ status: 'bar' }].sum).to eql(3.0)
      expect(summary.values[{ status: 'foo' }].sum).to eql(5.0)
    end
  end
end
