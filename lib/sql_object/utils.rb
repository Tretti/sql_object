module SqlObject
  module Utils
    def self.enforce_options(provided_options, required_options = [])
      missing_options = required_options - provided_options.keys
      raise ArgumentError, "Missing options: #{missing_options.join(', ')}, provided: #{provided_options.inspect}" if missing_options.any?
    end
  end
end
