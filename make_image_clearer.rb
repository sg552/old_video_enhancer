# encoding:utf-8
require "base64"
require 'httparty'
require 'json'

'''
图像清晰度增强
'''

request_url = "https://aip.baidubce.com/rest/2.0/image-process/v1/image_definition_enhance"
# 二进制方式打开图片文件
#f = File.read('/home/siwei/Documents/temp_mlt.jpg')
f = File.read('/home/siwei/Documents/result_level1.png')
img = Base64.encode64(f)

params = {"image":img}
access_token = "24.0e4058344aa57901cba7f28e57d08031.2592000.1627635217.282335-24469596"
request_url = request_url + "?access_token=" + access_token
headers = {'content-type': 'application/x-www-form-urlencoded'}

options = {
  body: { "image": img},
  headers: headers,
}

response = HTTParty.post(request_url, options)

File.open('result_level2.png', 'wb') do |f|
  f.write(Base64.decode64(JSON.parse(response.body)['image']))
end


puts response.code
puts JSON.parse(response.body)['log_id']

