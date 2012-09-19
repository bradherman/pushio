module PushIo
  class Configuration

    attr_accessor :app_guid
    attr_accessor :sender_secret
    attr_writer :endpoint_url

    def endpoint_url
      @endpoint_url || PushIo::ENDPOINT_URL
    end
  end
end

module PushIo
  ENDPOINT_URL = "https://manage.push.io"
  NOTIFY_APP_PATH = "/api/v1/notify_app/"
end