require 'rack'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

require 'prometheus/client/data_stores/mmap_store'
SSD_TMP_DIR = "/tmp/prometheus_test_script_example"
Prometheus::Client.config.data_store = Prometheus::Client::DataStores::MmapStore.new(dir: SSD_TMP_DIR)

use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

srand

app = lambda do |_|
  case rand
  when 0..0.8
    [200, { 'Content-Type' => 'text/html' }, ['OK']]
  when 0.8..0.95
    [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
  else
    # raise NoMethodError, 'It is a bug!'
    [500, { 'Content-Type' => 'text/html' }, ['Error']]
  end
end

run app
