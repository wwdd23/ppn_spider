# encoding: utf-8
require 'csv'

namespace :report_database do
  desc "云地接poi信息表格输出"

  task :location_report => :environment do 

    out = [["城市", "英文名称", "国家", "区域", "时区", "经纬度", "市内范围", "市外范围", "是否热门城市", "是否有价格"]]

    YdjPoi.all.each do |n|
      out << [
        n.cityName,
        n.cityEnName,
        n.placeName,
        n.continentName,
        n.timezone,
        n.location,
        n.intownTip,
        n.neighbourTip,
        n.isHotCity,
        n.hasPrice,
      ]
    end
    Emailer.send_custom_file(['diaoxu@haihuilai.com'],  "ydj—POI信息输出", XlsGen.gen(out), "ydj_poi信息.xls" ).deliver
  end

end
