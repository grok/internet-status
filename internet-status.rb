require 'json'
require 'rest_client'
require 'net/http'
require 'net/ping/http'

module Colors
  YELLOW = 18373 # Back up internet.
  GREEN = 25654 # Primary internet and speeds are OK
  RED = 65527 # Slow speeds -- regardless of ISP
end

module Addresses
  PRIMARY = '68.190.186.130'
  BACKUP = '66.224.72.122'
  HUB = '192.168.16.155'
  TEST = 'http://google.com' # What are we testing against?
  PUBLIC = RestClient.get 'http://whatismyip.akamai.com'
end

module Hue
  ID = '3'
  USERNAME = '2b1c0c93ae079efd83b8b19a6d67'
  API = "http://#{Addresses::HUB}/api/#{USERNAME}"
end

def check_internet
  on = false
  hue = Colors::RED

  request = Net::Ping::HTTP.new(Addresses::TEST)

  if request.ping
    puts "#{Time.now}	#{request.duration}"
    on = true
    if request.duration < 1
      if Addresses::PUBLIC == Addresses::PUBLIC
        hue = Colors::GREEN
      else
        puts "#{Time.now}	BACKUP INTERNET"
        hue = Colors::YELLOW
      end
    else
      hue = Colors::RED
    end
  else
    puts "#{Time.now} INTERNET DOWN"
    on = false
  end

  RestClient.put "#{Hue::API}/lights/#{Hue::ID}/state",
    { on: on, hue: hue, bri: 80, sat: 255, alert: 'select' }.to_json,
    content_type: :json,
    accept: :json
end

begin
  loop do
    check_internet
    sleep 10
  end
rescue => msg
  $stderr.puts "#{Time.now}	ERROR"
end
