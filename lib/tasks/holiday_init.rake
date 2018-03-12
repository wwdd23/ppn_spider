# encoding: utf-8
require 'csv'

namespace :want_world_holiday do

  desc "世界各国公共假期爬取"
  task :init_holiday_spider => :environment do

    Task.transaction do
      url = "https://publicholidays.global/"
      task_info = {
        url:  url,
        project: 'publicholiday',
        category: 'normal',
        script_name: 'publicholiday/init_holiday.js',
        context: "",
      }
      p task_info
      Task.create!(task_info)

    end
  end


  desc "世界各国假期邮件"
  task :report => :environment do
    data = $mongo_qspider['get_holiday.js'].find()
    x = data.to_a
    send = [["国家", "日期", "星期", "名称", "假期区域", "链接"]]
    x.each do |n|
      r = n["data"]
      country = r["country"]
      d = r["data"]
      d.each do |m|
        send << [country, m["time"], m["day"], m["holiday"], m["state"], n["url"]]
      end
    end
    Emailer.send_custom_file(['wudi@haihuilai.com'],  "世界各国公共假期信息", XlsGen.gen(send), "世界各国公共假期信息.xls",).deliver
  end

end
