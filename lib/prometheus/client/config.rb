# encoding: UTF-8

require 'prometheus/client/data_stores/synchronized'

module Prometheus
  module Client
    class Config
      attr_accessor :data_store
      attr_accessor :label_error_strategy

      def initialize
        @data_store = Prometheus::Client::DataStores::Synchronized.new
        @label_error_strategy = ErrorStrategies::Raise # we'll have a custom one, off-gem for Raven (or we can provide that one by default), and set it to that in production
      end
    end
  end
end
