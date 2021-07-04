
origin_folder = 'tmp_origin_image_folder'
target_folder = 'tmp_enlarged_image_folder'
prefix='vcd3_'
t = target_folder + '/*png'

# 1. 列出所有的缺失
#
sorted_file_index = Dir[t].map { |file_name|
  origin_file_name = file_name.gsub(target_folder + '/', '').gsub(prefix, '').gsub('.png', '')
  origin_file_name.to_i
}.sort()

# 获得最后一个图片index

puts "=== 缺少的:"
puts (1 .. sorted_file_index.last.to_i).to_a - sorted_file_index


puts "=== 多余的:"
puts sorted_file_index - (1 .. sorted_file_index.last.to_i).to_a

# 2. 列出所有大小是 0 的图片
#

puts "== 新产生的0大小的图片: "
origin_0_size_files = `find "#{origin_folder}" -size 0 -print`.split("\n").map{|e| e.gsub(origin_folder + '/', '')}
target_0_size_files = `find "#{target_folder}" -size 0 -print`.split("\n").map{|e| e.gsub(target_folder + '/', '')}

puts target_0_size_files - origin_0_size_files

