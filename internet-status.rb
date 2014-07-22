require 'json'
require 'rest_client'
require 'net/http'
require 'net/ping/http'

# @TODO: Check which ISP we are using.

def every_5_seconds
		last = Time.now
		while true
				yield
				now = Time.now
				_next = [last + 5,now].max
				sleep (_next-now)
				last = _next
		end
end

def check_internet
	hub_ip = '192.168.16.155'
	username = '2b1c0c93ae079efd83b8b19a6d67'
	api_path = 'http://' + hub_ip + '/api/' + username
	default = 'http://google.com'

	yellow = 20000 # Back up internet.
	green = 25500 # Primary internet and speeds are OK
	red = 0 # Slow speeds -- regardless of ISP

	request = Net::Ping::HTTP.new(default)
	if request.ping
		if request.duration < 1
			RestClient.put api_path + '/lights/3/state', {:on => true, :hue => green, :bri => 200}.to_json, :content_type => :json, :accept => :json
		else
			RestClient.put api_path + '/lights/3/state', {:on => true, :hue => red, :bri => 200}.to_json, :content_type => :json, :accept => :json
		end
	else
		RestClient.put api_path + '/lights/3/state', :on => 'false'
	end
end

every_5_seconds { check_internet }
