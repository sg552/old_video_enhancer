# encoding:utf-8
require "base64"
require 'httparty'
require 'json'
require './lib/logger_tool.rb'
require 'config'

Config.load_and_set_settings(Config.setting_files("./config/settings.yml", "development"))

'''
让图片无损放大
'''
# 可以使用一个月
access_token = '24.08bbec0d2a207e6b0eb513b767bc0270.2592000.1627810765.282335-'

@request_url = "https://aip.baidubce.com/rest/2.0/image-process/v1/image_quality_enhance?access_token=#{access_token}"

# 这个很重要

@logger = LoggerTool.get_logger

def get_index_from_file_name options
  @logger.info "== in get_index_from_file_name"
  @logger.info "== options: #{options.inspect}"
  index = options[:base_file_name].gsub(options[:file_prefix],'').gsub(options[:file_postfix], '').to_i
  return index
end

def run options
  origin_png = options[:origin_png]
  base_file_name = options[:base_file_name]

  http_options = {
    body: {"image":Base64.encode64(File.read(origin_png))},
    headers: {'content-type': 'application/x-www-form-urlencoded'},
  }

  response = HTTParty.post(@request_url, http_options)
  new_file_name = "#{options[:enlarged_image_folder]}/#{base_file_name}"

  @logger.info "== processing : #{new_file_name}"
  @logger.info response.code
  @logger.info response.body if response.code >= 300

  begin
    File.open(new_file_name, 'wb') { |f|
      f.write(Base64.decode64(JSON.parse(response.body)['image']))
    }
  rescue Exception => e
    @logger.error e
    @logger.error "== error, index: #{index}"
    @logger.error response
  end
end

# 二进制方式打开图片文件
ORIGIN_IMAGE_FOLDER = 'tmp_origin_image_folder'
IMAGE_TYPE = 'png'
FROM_INDEX = 1200
TO_INDEX = 1250
FILE_PREFIX = "vcd3_"

Dir["#{ORIGIN_IMAGE_FOLDER}/*.#{IMAGE_TYPE}"].sort.each do |origin_png|
  base_file_name = origin_png.gsub(ORIGIN_IMAGE_FOLDER + '/', '')
  index = get_index_from_file_name base_file_name: base_file_name, file_prefix: FILE_PREFIX, file_postfix: ".#{IMAGE_TYPE}"
  if index < FROM_INDEX
    @logger.info "== index is: #{index}, < #{FROM_INDEX} , skip"
    next
  end

  if index > TO_INDEX
    @logger.info "== index is: #{index}, > #{TO_INDEX} , return "
    return
  end

  run origin_png: origin_png,
    base_file_name: base_file_name,
    origin_image_folder: ORIGIN_IMAGE_FOLDER,
    enlarged_image_folder: 'tmp_enlarged_image_folder'

  sleep 0.1
end

