# encoding: UTF-8

require 'prometheus/client/data_stores/simple_hash'
require 'examples/data_store_example'

describe Prometheus::Client::DataStores::SimpleHash do
  subject { described_class.new }
  let(:metric_store) { subject.for_metric(:metric_name, metric_type: :counter) }

  it_behaves_like Prometheus::Client::DataStores

  it "does not accept Metric Settings" do
    expect do
      subject.for_metric(:metric_name,
                         metric_type: :counter,
                         metric_settings: { some_setting: true })
    end.to raise_error(Prometheus::Client::DataStores::SimpleHash::InvalidStoreSettingsError)
  end
end
