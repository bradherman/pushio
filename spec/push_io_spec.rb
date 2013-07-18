require "rspec"
require 'push_io'

describe PushIo do
  context "unconfigured" do
    it "should tell you how to configure" do
      expect { PushIo::Client.new }.to raise_error(PushIo::UnconfiguredClientError)

    end
  end
  context "configured" do
    test_keys_path = File.expand_path("../pushio_config.yml", __FILE__)
    test_keys = {}
    if File.exists? test_keys_path
      test_keys = YAML.load_file(test_keys_path)
    end
    let(:endpoint_url) { test_keys[:endpoint_url] || "https://manage.push.io" }
    let(:app_guid) { test_keys[:app_guid] || "abcdefghij" }
    let(:api_key) { test_keys[:api_key] || "abcdefghij_apns" }
    let(:sender_secret) { test_keys[:sender_secret] || "m42PGzAqQAdEcY1w2fpN" }
    let(:device_id) { test_keys[:device_id] || "B3606524-AE35-458A-9FE9-7B6FE8D99CE4" }
    let(:device_token) { test_keys[:device_token] || "abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd" }
    before :each do
      PushIo::Client.configure do |config|
        config.endpoint_url = endpoint_url
        config.app_guid = app_guid
        config.sender_secret = sender_secret
      end
    end
    it "should allow configuration" do
      client = PushIo::Client.new
      client.config.app_guid.should == app_guid
      client.config.sender_secret.should == sender_secret
      client.config.endpoint_url.should == endpoint_url
    end
    it "should allow configuration override" do
      client = PushIo::Client.new(:app_guid => "aaaa", :sender_secret => "qqqq")
      client.config.app_guid.should == "aaaa"
      client.config.sender_secret.should == "qqqq"
    end
    it "makes a send url" do
      client = PushIo::Client.new
      client.send(:send_url).should == "#{endpoint_url}/api/v1/notify_app/#{app_guid}/#{sender_secret}"
      client = PushIo::Client.new(:endpoint_url => "http://localhost:3000", :app_guid => "aaaa", :sender_secret => "qqqq")
      client.send(:send_url).should == "http://localhost:3000/api/v1/notify_app/aaaa/qqqq"
    end

    it "sends inlined" do
      notification_id = PushIo::Client.new.deliver_broadcast :payload => {:message => "Inlined Test"}
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end
    it "sends a generic push" do
      client = PushIo::Client.new
      client.send(:httpclient).send(:debug_dev=, STDOUT)
      notification_id = client.deliver :payload => {:message => "Generic Test"}, :tag_query => "Alpha or Bravo"
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end
    it "sends a broadcast" do
      client = PushIo::Client.new
      client.send(:httpclient).send(:debug_dev=, STDOUT)
      notification_id = client.deliver_broadcast :payload => {:message => "Broadcast Test"}
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end
    it "sends to an audience" do
      client = PushIo::Client.new
      client.send(:httpclient).send(:debug_dev=, STDOUT)
      notification_id = client.deliver_to_audience "broadcast", :payload => {:message => "Howdy Friends", :payload_apns => {:badge => 8}}
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end
    it "sends a query push" do
      client = PushIo::Client.new
      client.send(:httpclient).send(:debug_dev=, STDOUT)
      notification_id = client.deliver_to_query "Alpha or Bravo", :payload => {:message => "Query Test"}
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end

    it "sends to device ids" do
      client = PushIo::Client.new
      client.send(:httpclient).send(:debug_dev=, STDOUT)
      notification_id = client.deliver_to_ids api_key, [device_id], :payload => {:message => "Device ID Test"}
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end

    it "sends to device tokens" do
      client = PushIo::Client.new
      client.send(:httpclient).send(:debug_dev=, STDOUT)
      notification_id = client.deliver_to_tokens api_key, [device_token], :payload => {:message => "Device Token Test"}
      notification_id.should_not be_nil
      notification_id.should start_with app_guid
    end
  end


end