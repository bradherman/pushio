module PushIo
  class Client
    attr_reader :config
    attr_accessor :httpclient

    def initialize(attributes = {})
      @config = PushIo::Client.config.dup
      self.httpclient = HTTPClient.new
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

    def deliver(*args)
      opts = args.extract_options!
      send_post(opts) if ready_to_deliver?(opts)
    end

    def deliver_broadcast(*args)
      opts = args.extract_options!
      opts.delete(:audience) if opts[:audience]
      opts.delete(:tag_query) if opts[:tag_query]
      opts[:audience] = 'broadcast'
      send_post(opts) if ready_to_deliver?(opts)
    end

    def deliver_to_audience(audience, *args)
      opts = args.extract_options!
      opts.delete(:tag_query) if opts[:tag_query]
      opts[:audience] = audience
      raise PushIo::MissingOptionsError, "An audience was not specified" unless opts[:audience]
      send_post(opts) if ready_to_deliver?(opts)
    end

    def deliver_to_query(query, *args)
      opts = args.extract_options!
      opts.delete(:audience) if opts[:audience]
      opts[:tag_query] = query
      raise PushIo::MissingOptionsError, "A query was not specified" unless opts[:tag_query]
      send_post(opts) if ready_to_deliver?(opts)
    end

    def deliver_to_ids(api_key, device_id_array, *args)
      opts = args.extract_options!
      opts.delete(:audience) if opts[:audience]
      opts.delete(:tag_query) if opts[:tag_query]
      raise PushIo::MissingOptionsError, "A valid API Key was not specified" unless api_key =~ PushIo::API_KEY_REGEX
      raise PushIo::MissingOptionsError, "Device IDs need to be specified in an array" unless device_id_array.is_a? Array
      opts[:recipient_ids] = {api_key => device_id_array}
      send_devices_post(opts) if ready_to_deliver_to_devices?(opts)
    end

    def deliver_to_tokens(api_key, device_token_array, *args)
      opts = args.extract_options!
      opts.delete(:audience) if opts[:audience]
      opts.delete(:tag_query) if opts[:tag_query]
      raise PushIo::MissingOptionsError, "A valid API Key was not specified" unless api_key =~ PushIo::API_KEY_REGEX
      raise PushIo::MissingOptionsError, "Device tokens need to be specified in an array" unless device_token_array.is_a? Array
      opts[:recipient_tokens] = {api_key => device_token_array}
      send_devices_post(opts) if ready_to_deliver_to_devices?(opts)
    end

    def deliver_to_location(api_key, *args)
      opts = args.extract_options!
      raise PushIo::MissingOptionsError, "A latitude was not specified" unless opts[:lat]
      raise PushIo::MissingOptionsError, "A longitude was not specified" unless opts[:lon]
      raise PushIo::MissingOptionsError, "A distance was not specified" unless opts[:dist]
      send_location_post(opts)
    end

    private

    def ready_to_deliver?(opts)
      if (opts.keys & [:tag_query, :audience]).empty?
        raise PushIo::MissingOptionsError, "No tag_query or audience was specified"
      end
      if (opts.keys & [:tag_query, :audience]).length == 2
        raise PushIo::MissingOptionsError, "Please specify tag_query or audience but not both"
      end
      raise PushIo::MissingOptionsError, "Please specify a payload" unless opts[:payload]
      true
    end

    def send_url
      "#{@config.endpoint_url}#{PushIo::NOTIFY_APP_PATH}#{@config.app_guid}/#{@config.sender_secret}"
    end

    def send_post(opts)
      response = self.httpclient.post(send_url, {:body => build_post(opts)})
      parse_response(response)
    end

    def send_location_post(opts)
      response = self.httpclient.post(send_url, {body: build_loc(opts)}
      parse_response(response)
    end

    def build_loc(opts)
      {location_query: {reg: {lat: opts[:lat], lon: opts[:lon], dist: opts[:dist]}}}
    end

    def build_post(opts)
      opts[:payload] = MultiJson.dump(opts[:payload])
      opts[:recipient_ids] = MultiJson.dump(opts[:recipient_ids]) if opts[:recipient_ids]
      opts[:recipient_tokens] = MultiJson.dump(opts[:recipient_tokens]) if opts[:recipient_tokens]
      opts
    end

    def parse_response(response)
      if response.code == 201
        response_hash = MultiJson.load(response.body)
        return response_hash['notification_guid']
      end
      raise PushIo::DeliveryError, response.body
    end


    def send_devices_url
      "#{@config.endpoint_url}#{PushIo::NOTIFY_DEVICES_PATH}#{@config.app_guid}/#{@config.sender_secret}"
    end

    def send_devices_post(opts)
      response = self.httpclient.post(send_devices_url, {:body => build_post(opts)})
      parse_response(response)
    end

    def ready_to_deliver_to_devices?(opts)
      if (opts.keys & [:recipient_ids, :recipient_tokens]).empty?
        raise PushIo::MissingOptionsError, "No tag_query or audience was specified"
      end
      if (opts.keys & [:recipient_ids, :recipient_tokens]).length == 2
        raise PushIo::MissingOptionsError, "Please specify recipient_ids or recipient_tokens but not both"
      end
      raise PushIo::MissingOptionsError, "Please specify a payload" unless opts[:payload]
      true
    end

  end
end