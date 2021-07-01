client_id = ENV['client_id']
client_secret = ENV['client_secret']

url = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=#{client_id}&client_secret=#{client_secret}"

require 'httparty'

response = HTTParty.get url
puts response.inspect
