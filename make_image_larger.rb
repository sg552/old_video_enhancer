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
access_token = File.read('ACCESS_TOKEN.txt')

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

  begin
    response = HTTParty.post(@request_url, http_options)
    new_file_name = "#{options[:enlarged_image_folder]}/#{base_file_name}"

    @logger.info "== processing : #{new_file_name}"
    @logger.info response.code
    @logger.info response.body if response.code >= 300

    File.open(new_file_name, 'wb') { |f|
      f.write(Base64.decode64(JSON.parse(response.body)['image']))
    }
  rescue Exception => e
    @logger.error e
    @logger.error e.backtrace.join("\n")
    @logger.error response
  end
end

# 二进制方式打开图片文件
ORIGIN_IMAGE_FOLDER = 'tmp_origin_image_folder'
IMAGE_TYPE = 'png'
FILE_PREFIX = "vcd3_"

MISSING_IMAGES = %w{
vcd3_00000026.png
vcd3_00000025.png
vcd3_00000030.png
vcd3_00000021.png
vcd3_00000027.png
vcd3_00000024.png
vcd3_00000022.png
vcd3_00000028.png
vcd3_00000029.png
vcd3_00000023.png
vcd3_00000031.png
vcd3_00000040.png
vcd3_00000032.png
vcd3_00000039.png
vcd3_00000037.png
vcd3_00000034.png
vcd3_00000038.png
vcd3_00000036.png
vcd3_00000033.png
vcd3_00000035.png
vcd3_00000054.png
vcd3_00000056.png
vcd3_00000058.png
vcd3_00000055.png
vcd3_00000052.png
vcd3_00000057.png
vcd3_00000059.png
vcd3_00000060.png
vcd3_00000051.png
vcd3_00000053.png
vcd3_00000067.png
vcd3_00000068.png
vcd3_00000061.png
vcd3_00000063.png
vcd3_00000064.png
vcd3_00000077.png
vcd3_00000080.png
vcd3_00000071.png
vcd3_00000079.png
vcd3_00000076.png
vcd3_00000120.png
vcd3_00000116.png
vcd3_00000117.png
vcd3_00000113.png
vcd3_00000112.png
vcd3_00000114.png
vcd3_00000111.png
vcd3_00000118.png
vcd3_00000115.png
vcd3_00000119.png
vcd3_00000133.png
vcd3_00000135.png
vcd3_00000136.png
vcd3_00000134.png
vcd3_00000132.png
vcd3_00000138.png
vcd3_00000139.png
vcd3_00000140.png
vcd3_00000131.png
vcd3_00000137.png
vcd3_00000157.png
vcd3_00000153.png
vcd3_00000152.png
vcd3_00000156.png
vcd3_00000159.png
vcd3_00000151.png
vcd3_00000158.png
vcd3_00000154.png
vcd3_00000168.png
vcd3_00000170.png
vcd3_00000713.png
vcd3_00031889.png
vcd3_00033371.png
vcd3_00036590.png
vcd3_00044762.png
vcd3_00045715.png
vcd3_00045763.png
vcd3_00045800.png
vcd3_00045808.png
vcd3_00045873.png
vcd3_00046052.png
vcd3_00046116.png
vcd3_00046124.png
vcd3_00046309.png
vcd3_00046347.png
vcd3_00046374.png
vcd3_00046596.png
vcd3_00046624.png
vcd3_00046715.png
vcd3_00046793.png
vcd3_00046821.png
vcd3_00046827.png
vcd3_00046956.png
vcd3_00047066.png
vcd3_00047125.png
vcd3_00047124.png
vcd3_00047167.png
vcd3_00047199.png
vcd3_00047213.png
vcd3_00047220.png
vcd3_00047218.png
vcd3_00047292.png
vcd3_00047413.png
vcd3_00047631.png
vcd3_00047665.png
vcd3_00047669.png
vcd3_00047758.png
vcd3_00047839.png
vcd3_00048893.png
vcd3_00048911.png
vcd3_00049049.png
vcd3_00049052.png
vcd3_00049562.png
vcd3_00061610.png
vcd3_00061618.png
vcd3_00061625.png
vcd3_00061626.png
vcd3_00067727.png
vcd3_00069471.png
vcd3_00070129.png
vcd3_00070122.png
vcd3_00070123.png
vcd3_00070151.png
vcd3_00071023.png
vcd3_00071421.png
vcd3_00072024.png
vcd3_00080398.png
vcd3_00080400.png
vcd3_00082380.png
vcd3_00083001.png
}

target = []
if MISSING_IMAGES == []
  @logger.info "== normal mode"
  BATCH = 10
  target = Dir["#{ORIGIN_IMAGE_FOLDER}/*.#{IMAGE_TYPE}"]
  FROM_INDEX = 83600
  TO_INDEX = 83600
else
  @logger.info "== missing image mode"
  BATCH = 1
  target = MISSING_IMAGES.map{ |e| ORIGIN_IMAGE_FOLDER + '/' + e }
  FROM_INDEX = 0
  TO_INDEX = 10000000000
end
puts "== hi, target.size: #{target.size}"


target.sort.each_slice(BATCH) do |origin_pngs|
  threads = []
  if BATCH == 1
    @logger.info "== BATCH = 1, origin_pngs:  #{origin_pngs.inspect}"
  end
  origin_pngs.each do |origin_png|
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

    t = Thread.new {
      run origin_png: origin_png,
        base_file_name: base_file_name,
        origin_image_folder: ORIGIN_IMAGE_FOLDER,
        enlarged_image_folder: 'tmp_enlarged_image_folder'
    }
    threads << t
  end
  threads.each { |t| t.join }
end

