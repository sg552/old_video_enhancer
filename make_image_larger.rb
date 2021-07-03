# encoding:utf-8
require "base64"
require 'httparty'
require 'json'
require './lib/logger_tool.rb'

'''
让图片无损放大
'''
# 可以使用一个月
access_token = '24.08bbec0d2a207e6b0eb513b767bc0270.2592000.1627810765.282335-'

request_url = "https://aip.baidubce.com/rest/2.0/image-process/v1/image_quality_enhance?access_token=#{access_token}"

# 这个很重要
@file_prefix = 'vcd3_'
@file_postfix = '.png'

origin_image_folder = 'tmp_origin_image_folder'
enlarged_image_folder = 'tmp_enlarged_image_folder'

@logger = LoggerTool.get_logger

# 二进制方式打开图片文件
Dir["#{origin_image_folder}/*.png"].sort.each do |origin_png|

  base_file_name = origin_png.gsub(origin_image_folder + '/', '')
  index = base_file_name.gsub(@file_prefix,'').gsub(@file_postfix, '').to_i
  if index < 566
    @logger.info "== index is: #{index}, <= 477, skip"
    next
  end

  options = {
    body: {"image":Base64.encode64(File.read(origin_png))},
    headers: {'content-type': 'application/x-www-form-urlencoded'},
  }

  response = HTTParty.post(request_url, options)
  new_file_name = "#{enlarged_image_folder}/#{base_file_name}"
  puts "== request_url: #{request_url}, new_file_name: #{new_file_name}"

  @logger.info "== processing : #{new_file_name}"
  @logger.info response.code
  @logger.info response.body if response.code >= 300

  begin
    File.open(new_file_name, 'wb') do |f|
      f.write(Base64.decode64(JSON.parse(response.body)['image']))
    end
  rescue Exception => e
    @logger.error e
    @logger.error "== error, index: #{index}"
    @logger.error response
  end

  sleep 0.1
end

