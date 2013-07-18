# PushIoClient

An easy to use client for integrating push notifications into Ruby-based applications.
This gem uses the Push IO API to trigger notification delivery to whatever audience you specify.
In order to get full use of this gem you will need to have an active account on
https://manage.push.io and have recipient devices registered to receive notifications.
Learn more at http://push.io

## Installation

Add this line to your application's Gemfile:
```
    gem 'pushio'
```

And then execute:

```
    $ bundle
```

Or install it yourself as:

```
    $ gem install pushio
```


## Usage

Configure the client:

```ruby
PushIo::Client.configure do |config|
  config.app_guid = [your app guid from https://manage.push.io]
  config.sender_secret = [for your app on https://manage.push.io]
end
```

Send a broadcast push to everyone registered for your app:
```ruby
notification_id = PushIo::Client.deliver_broadcast :payload => {:message => "Broadcast Test"}
```

Send a push to an audience:
```ruby
notification_id = PushIo::Client.deliver_to_audience "friends", :payload => {:message => "Howdy Friends", :payload_apns => {:badge => 8}}
```

Send a push to a targeted query:
```ruby
notification_id = PushIo::Client.deliver_to_query "Alpha or Bravo", :payload => {:message => "Query Test"}
```

Send a push to a known device ID:
```ruby
notification_id = PushIo::Client.deliver_to_ids "APIKEY1234_a123", ['B3606524-AE35-458A-9FE9-7B6FE8D99CE4'], :payload => {:message => "Hello Push IO"}
```

Send a push to a known device Token:
```ruby
notification_id = PushIo::Client.deliver_to_tokens "APIKEY1234_a123", ['abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd'], :payload => {:message => "Hello Push IO"}
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
