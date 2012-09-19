# PushIoClient

An easy to use client for integrating push notifications into Ruby-based applications. This gem uses the Push IO API to trigger notification delivery to whatever audience you specify. In order to get full use of this gem you will need to have an active account on https://manage.push.io and have recipient devices registered to receive notifications. Learn more at http://push.io

## Installation

Add this line to your application's Gemfile:

    gem 'push_io_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install push_io_client

## Usage

Configure the client:

```
PushIo::Client.configure do |config|
  config.app_guid = [your app guid from https://manage.push.io]
  config.sender_secret = [for your app on https://manage.push.io]
end
```

Send a broadcast push to everyone registered for your app:
```
push_client = PushIo::Client.new
notification_id = push_client.broadcast :message => "Hello everyone!"
```

Send a push to an audience:
```
push_client.deliver_to_audience "friends", :message => "Howdy friends", :count => 8
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
