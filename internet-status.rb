require 'json'
require 'rest_client'
require 'net/http'
require 'net/ping/http'

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
	lightbulb_id = 3
	primary_internet = '68.190.186.130'
	backup_internet = '66.224.72.122'
	hub_ip = '192.168.16.155'
	username = '2b1c0c93ae079efd83b8b19a6d67'
	api_path = 'http://' + hub_ip + '/api/' + username
	default = 'http://google.com'

	on = false
	hue = red
	yellow = 20000 # Back up internet.
	green = 25500 # Primary internet and speeds are OK
	red = 0 # Slow speeds -- regardless of ISP

	request = Net::Ping::HTTP.new(default)
	if request.ping
		if request.duration < 1
			public_ip = RestClient.get 'http://whatismyip.akamai.com'
			on = true
			if public_ip == primary_internet
				hue = green
			else
				hue = yellow
			end
		else
			hue = red
		end
			on = false
	else

	end
	RestClient.put api_path + '/lights/' + lightbulb_id + '/state', {:on => on, :hue => hue, :bri => 200}.to_json, :content_type => :json, :accept => :json
end

every_5_seconds { check_internet }
