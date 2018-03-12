# encoding: utf-8
require 'csv'

namespace :spider_booking do
  desc "Booking 页面抓取init task"
  task :task_init => :environment do

    Task.transaction do

        task_info = {
          url: "https://www.booking.com/searchresults.zh-cn.html?aid=304142&label=gen173nr-1DCAsodUIZdGhlLXdlc3Rpbi1ydXN1dHN1LXJlc29ydEgrYgVub3JlZmgxiAEBmAEyuAEHyAEM2AED6AEB-AECkgIBeagCAw&sid=71e2d86af032098627d8a1e348e7663d&checkin_month=4&checkin_monthday=23&checkin_year=2017&checkout_month=4&checkout_monthday=25&checkout_year=2017&class_interval=1&dest_id=106&dest_type=country&group_adults=2&group_children=0&label_click=undef&mih=0&no_rooms=1&raw_dest_type=country&room1=A%2CA&sb_price_type=total&src=searchresults&src_elem=sb&ss=%E6%97%A5%E6%9C%AC&ssb=empty&ssne=%E6%97%A5%E6%9C%AC&ssne_untouched=%E6%97%A5%E6%9C%AC&rows=15",
          project:'casper_booking',
          category: 'normal',
          script_name: 'casper_booking/booking_init_plane_b.js',
          context: '',
        }
        Task.create!(task_info)
    end
  end

  desc "Booking poi数据发送"
  task :poi_data => :environment do


    send = [["酒店名称", "中文名称","中文地址", "国家", "城市", "lat", "lng", "类型", "附近机场", "链接"]]
    $mongo_qspider['booking_info.js'].find().each do |n|
      res = n["data"]
      airport = res["airport"]
      p airport
      airinfo = []
      if airport.count != 0
        airport.each do |air|
          airinfo << [air["airport"], air["distanc"]]
        end
      end

      send << [res["hotel"], res["name_cn"], res["address"], res['addressCountry'],
               res['addressRegion'],
               res["lat"], res["lng"], res["type"], airinfo, res["url"]]
    end
      Emailer.send_custom_file(['wudi@haihuilai.com'], 'Booking日本POI信息抓取数据', XlsGen.gen(send.uniq), 'Booking日本POI信息抓取数据.xls', true).deliver
  end
end
