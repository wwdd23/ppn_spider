# encoding: utf-8

namespace :generate_task_info_json do
  desc '查询所有解析脚本的生成时间生成json文件'
  task :generate_info_json => :environment do
    files = []
    Dir['public/scripts/**/*'].each do |file|
      next if File.directory?(file)
      fs = File::Stat.new(file)
      mtime = fs.mtime.strftime('%Y-%m-%d %H:%M:%S')
      file_info = {
        name: file.gsub('public/scripts/', ''),
        modified_at: mtime 
      }
      files << file_info
    end

    f = File.open('public/scripts/versions.json', 'w')
    f.write(files.to_json)
    f.close
  end
end
