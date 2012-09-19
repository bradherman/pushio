require "rspec"
require 'push_io'

describe PushIo do
  context "unconfigured" do
    it "should tell you how to configure" do
      expect{PushIo::Client.new}.to raise_error(PushIo::UnconfiguredClientError)

    end
  end
  context "configured" do
    before :each do
      PushIo::Client.configure do |config|
        config.app_guid = "1234"
        config.sender_secret = "5678"
      end
    end
    it "should allow configuration" do
      client = PushIo::Client.new
      client.config.app_guid.should == "1234"
      client.config.sender_secret.should == "5678"
    end
    it "should allow configuration override" do
      client = PushIo::Client.new(:app_guid => "aaaa", :sender_secret => "qqqq")
      client.config.app_guid.should == "aaaa"
      client.config.sender_secret.should == "qqqq"
    end
    it "makes a send url" do
      client = PushIo::Client.new
      client.send(:send_url).should == "https://manage.push.io/api/v1/notify_app/1234/5678"
      client = PushIo::Client.new(:app_guid => "aaaa", :sender_secret => "qqqq")
      client.send(:send_url).should == "https://manage.push.io/api/v1/notify_app/aaaa/qqqq"
      client = PushIo::Client.new(:endpoint_url => "http://somewhere.else.entirely.org")
      client.send(:send_url).should == "http://somewhere.else.entirely.org/api/v1/notify_app/1234/5678"
    end
  end


end