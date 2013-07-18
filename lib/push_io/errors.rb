module PushIo
  class UnconfiguredClientError < StandardError
  end
  class MissingOptionsError < StandardError
  end
  class DeliveryError < StandardError
  end
end