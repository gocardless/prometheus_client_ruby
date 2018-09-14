module ErrorStrategies
  class Raise
    def self.label_error(exception_klass, message)
      raise exception_klass, message
    end
  end
end