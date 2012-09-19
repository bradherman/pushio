module PushIo
  class Client
    attr_reader :config
    def initialize(attributes = {})
      @config = PushIo::Client.config.dup
      attributes.each do |name, value|
        @config.send("#{name}=", value) if @config.respond_to?("#{name}=")
      end
      if (@config.app_guid.nil? || @config.app_guid == '' || @config.sender_secret.nil? || @config.sender_secret == '')
        raise UnconfiguredClientError, "You must specify a Push IO service app_guid and sender_secret either in an initializer or when creating your PushIo::Client instance"
      end
    end

    class << self
      attr_accessor :configuration

      def config
        self.configuration ||= Configuration.new
      end

      def configure
        yield(config)
      end
    end

    def broadcast(*payload)
      send_post(payload, {:audience => "broadcast"})
    end

    def deliver_to_audience(audience, *payload)
      send_post(payload, {:audience => audience})
    end

    private
    def send_url
      "#{@config.endpoint_url}#{PushIo::NOTIFY_APP_PATH}#{@config.app_guid}/#{@config.sender_secret}"
    end
    def send_post(payload, args)
      response = HTTPClient.new.post(send_url, {:body => build_post(args, payload)})
    end
    def build_post(args, payload)
      args.merge({:payload => MultiJson.dump(payload)})
    end
  end
end