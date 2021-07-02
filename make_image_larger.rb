# encoding:utf-8
require "base64"
require 'httparty'
require 'json'
require './lib/logger_tool.rb'

'''
让图片无损放大
'''

access_token = '24.5499bd61ab43a9784f9cdb9d392b038d.2592000.1627798482.282335-24469596'

request_url = "https://aip.baidubce.com/rest/2.0/image-process/v1/image_quality_enhance"

origin_image_folder = 'tmp_origin_image_folder'
enlarged_image_folder = 'tmp_enlarged_image_folder'

@@logger = LoggerTool.get_logger

# 二进制方式打开图片文件
Dir["#{origin_image_folder}/*.png"].sort.each do |origin_png|

  base_file_name = origin_png.gsub(origin_image_folder + '/', '')
  index = base_file_name.gsub('vcd3-','').gsub('.png', '').to_i
  if index < 300
    @@logger.info "== index is: #{index}, <= 300, skip"
    next
  end

  f = File.read(origin_png)
  img = Base64.encode64(f)

  params = {"image":img}
  request_url = request_url + "?access_token=" + access_token
  headers = {'content-type': 'application/x-www-form-urlencoded'}

  options = {
    body: { "image": img},
    headers: headers,
  }

  response = HTTParty.post(request_url, options)

  new_file_name = "#{enlarged_image_folder}/#{base_file_name}"

  @@logger.info "== processing : #{new_file_name}"
  @@logger.info response.code
  @@logger.info response.body if response.code >= 300

  begin
    File.open(new_file_name, 'wb') do |f|
      f.write(Base64.decode64(JSON.parse(response.body)['image']))
    end
  rescue Exception => e
    @@logger.error e
    @@logger.error response.body
  end

  sleep 0.1
end

