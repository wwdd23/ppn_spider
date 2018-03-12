# encoding: utf-8
require 'csv'

namespace :create_ctrip do


  desc "携程任务抓取比价数据邮件(阿拉丁)"
  task :report_alading => :environment do
    start_day = 1.day.ago.to_date.to_time
    end_day = start_day.end_of_day
    data = $mongo_qspider['day_ctrip_casper.js'].find(:created_at => {:$gte => start_day,:$lte => end_day})
    count = 1
    result = data.to_a; nil
    out = [["请求时间", "城市", "服务日期", "服务时间", "行程天数", "行程内容", "车型", "最低价", "价差", "最大可乘人数", \
            "行李数", "评分", "价格", "名次", "供应商", "服务"]]
    result.each do |n|
      p count = count + 1
      res = n["data"]
      context = n["context"]
      reg_info = context["text"].match(/refs=(.*)&iscross/)[1]
      log_time = context["time"].to_time #请求时间 log 获取
      refs = JSON.parse(reg_info)
      duration = context["text"].match(/duration=(\d+)&refs/)[1] #行程天数
      items_cn = refs["items"].map{|m| m["desctription"]}
      city = res["city_cn"]
      time = res["time"]
      date = res["date"]
      type_cn = res["type_cn"]

      res["data"].each do |m|
        name = m["name"]
        lowprice = m["lowprice"]
        passenger = m["passenger"]
        num = m["num"] #此车型有几个价格
        baggager = m["baggager"]

        step = 0 # 排名
        m["datas"].each do |p| #车型数据
          step = step + 1
          score = p["score"]
          sprice = p["sprice"]
          service = p["service"]
          supply = p["supply"]
          out << [log_time, city, date, time, type_cn, items_cn, name, lowprice, (sprice - lowprice), passenger, baggager, score, sprice, step, supply, service]
        end
      end
    end

    Emailer.send_custom_file(['ctrip-pro@haihuilai.com'],  "【携程访问数据抓取】-#{start_day.to_date.to_s}", XlsGen.gen(out), "【携程访问数据抓取】#{start_day.to_date.to_s}.xls", true ).deliver
  end

  desc "携程任务抓取自动化URL比价(阿拉丁)"
  task :alading => :environment do
    #date = Time.parse(ENV["date"] || Time.now.to_date.to_s)

    # date =  63.minutes.ago.to_time #每30分钟执行一次
    date = (Time.now - 1.hour).beginning_of_hour
    Task.transaction do
      data = $analysis_data["ctrip_spiders"].find({:created_at =>  {:$gte => date}})
      datas = data.to_a
      return if datas.nil?
      datas.each do |n|
        res = n["res"]
        r_date = res["UseDate"]
        city_id = res["CityID"] 
        duration = res["UseDuration"] 
        log_time = n["created_at"].to_time
        r_items = []

        res["ScheduleList"].each do |x|
          days = x["Days"]
          type = x["UseType"]
          city_ids = [x["DepartCityId"]]
          #r_items << JSON.parse({"cityIds":city_ids, "day":days,"pathType":type})
          name = x["DepartCityName"]
          case type
          when 1
            des = "市内包车服务"
            r_items << {"cityIds":[], "day":days,"pathType":type,  "desctription": "#{name}#{des}"}
          when 2
            des = "周边包车服务"
            r_items << {"cityIds":city_ids, "day":days,"pathType":type,  "desctription": "#{name}#{des}"}
          end
        end
        refs_data = ({"cityId" => city_id,"items" => r_items, }).to_json
        s = ("date=#{r_date}&duration=#{duration}&refs=#{refs_data}&iscross=false&isreturn=false&staydur=0")
        url = "http://car.ctrip.com/dayweb/city#{city_id}?"

        task_info = {
          url:  URI.escape(url + s),
          project:'ctrip_qwb',
          category: 'normal',
          script_name: 'ctrip_qwb/day_ctrip_casper.js',
          context: {:time => log_time, :text => s}.to_json,
        }
        p task_info
        Task.create!(task_info)
      end
    end
  end

  desc "携程任务抓取自动化URL"
  task :air_booking => :environment do

    info = CSV.read(ENV['file_path'] || 'data/searchlocation.csv')
    all_url = []
    time_list = [ "2017-5-6",  "2017-6-14",  "2017-4-14", "2017-04-29", ]
    time_list.each do |date|
      info.each do |res|
        (17..18).each do |type|
          base_url = "http://car.ctrip.com/hwdaijia/list?ptType=#{type}&cid=#{res[0]}&useDt=#{date}%2009:00&flNo=&dptDt=0001-01-01%2000:00&locNm=&locCd=#{res[1]}&locType=1&locSubCd=&locSubType=0&poiCd=&poiType=2&poiNm=#{res[2]}&poiAddr=&poiLng=#{res[3]}&poiLat=#{res[4]}&poiref=&addrsource=se&chtype=2"
          #all_url << base_url
          File.open('/tmp/ctrip_url.txt', 'a') {|f| f.write("#{base_url}\n")}
        end
      end
    end
  end

  desc "小红书任务抓取自动化URL"
  task :xhs_data => :environment do
    Task.transaction do
      url = "http://www.xiaohongshu.com/api/discovery/list2?&_r=1490062859642&start=58afc75cb46c5d77d06c4438&num=200&oid=category.52ce1c02b4c4d649b58b892c"
      task_info = {
        url: url,
        project:'ctrip_qwb',
        category: 'normal',
        script_name: 'ctrip_qwb/xiaohongshu.js',
        context: '',
      }
      Task.create!(task_info)
    end
  end

  desc "携程接送机任务"
  task :air_spider => :environment do

    a = File.read("/tmp/ctrip_url.txt")
    x = a.split("\n")
    Task.transaction do
      x.each do |url|
        #next if index == 0

        task_info = {
          url: url,
          project:'ctrip_qwb',
          category: 'normal',
          script_name: 'ctrip_qwb/air_ctrip_casper.js',
          context: '',
        }
        Task.create!(task_info)
        p url
      end
    end
  end

  desc "携程接送机任务"
  task :tmp_air_spider => :environment do
    a = CSV.read("data/sort_air.csv")

    a.each do |res|
      (17..18).each do |type|
        #date = res[5].split('-')[1].gsub("/","-")

        date = rand((Time.now + 2.days).to_date..res[5].split('-')[1].to_date).to_s



        base_url = "http://car.ctrip.com/hwdaijia/list?ptType=#{type}&cid=#{res[0]}&useDt=#{date}%2009:00&flNo=&dptDt=0001-01-01%2000:00&locNm=&locCd=#{res[1]}&locType=1&locSubCd=&locSubType=0&poiCd=&poiType=2&poiNm=#{res[2]}&poiAddr=&poiLng=#{res[3]}&poiLat=#{res[4]}&poiref=&addrsource=se&chtype=2"
        Task.transaction do
          task_info = {
            url: base_url,
            project:'ctrip_qwb',
            category: 'normal',
            script_name: 'ctrip_qwb/air_ctrip_casper.js',
            context: '',
          }
          Task.create!(task_info)
        end
      end
    end
  end



  desc "携程一日包车抓取自动化URL"
  task :day_booking => :environment do

    # info = CSV.read(ENV['file_path'] || 'data/searchlocation.csv')
    # city_id 
    time_list = [ "2017-5-6",  "2017-6-14",  "2017-4-14", "2017-04-29", ]
    city_name=["东京","大阪","伦敦","札幌","巴黎","新加坡","首尔","那霸","布拉格","悉尼","京都","洛杉矶","罗马","巴塞罗那","马德里","曼谷","台北","旧金山","多伦多","名古屋"]

    ds = CSV.read('data/ctrip_city.csv')
    res = []
    ds.each do |n|
      res << {
        "city" => n[1],
        "id" => n[0],
        "country" => n[2],
      }
    end
    #city_id = [228, 207, 219, 725]
    city_id = []
    city_name.each do |name|
      p res.select{|n| n["city"] == name}
      next unless res.select{|n| n["city"] == name}.present?
      city_id << res.select{|n| n["city"] == name}.first["id"].to_i
    end
    Task.transaction do 

      city_id.each do |id|
        time_list.each do |time|
          url = "http://car.ctrip.com/dayweb/city#{id}?date=#{time}%2009:00&duration=1&iscross=false&isreturn=false&staydur=0"
          task_info = {
            url: url,
            project:'ctrip_qwb',
            category: 'normal',
            script_name: 'ctrip_qwb/day_ctrip_casper.js',
            context: '',
          }
          Task.create!(task_info)
          p url 
        end
      end
    end
  end

  desc "携程60天包车数据爬取"
  task :tmp_60_day_booking => :environment do

    # info = CSV.read(ENV['file_path'] || 'data/searchlocation.csv')
    # city_id 
    time_span = Time.now.tomorrow.to_date..Time.parse("2017-06-15")
    city_name = ["爱丁堡", "伯明翰", "伦敦", "曼彻斯特", "尼斯", "马赛", "布拉格", "法兰克福", "杜赛尔多夫", "都灵", "雅典", "布鲁塞尔", "里斯本", "巴黎"]
    #city_get = CSV.read('data/ctrip_day_city.csv')
    ds = CSV.read('data/ctrip_city.csv')
    res = []
    ds.each do |n|
      res << {"city" => n[1], "id" => n[0], "country" => n[2],}
    end

    send_info = []
    city_name.each do |n|
      select = res.select{|m| m["city"] == n}
      next unless select.present? 
      time_span.each do |time|
        send_info << [select.first["id"].to_i, time.to_s, n]
      end
    end
    Task.transaction do 
      send_info.each do |n|
        url = "http://car.ctrip.com/dayweb/city#{n[0]}?date=#{n[1]}%2009:00&duration=1&iscross=false&isreturn=false&staydur=0"
        task_info = {
          url: url,
          project:'ctrip_qwb',
          category: 'normal',
          script_name: 'ctrip_qwb/day_ctrip_casper.js',
          context: '',
        }
        Task.create!(task_info)
        p url 
      end
    end
  end




  desc "初始化竞争对手价格爬取任务"
  task :init_mafengwo_price => :environment do
    mafengwo_house = CSV.read('data/mafengwo_house.csv')

    Task.transaction do
      mafengwo_house.each_with_index do |row, index|
        next if index == 0

        task_info = {
          url: "http://www.mafengwo.cn/hotel/#{row[4]}.html",
          project:'kancho',
            category: 'normal',
            script_name: 'kancho/kancho_mfw_assignPriceTask.py',
            context: '',
        }
        Task.create!(task_info)
        p "http://www.mafengwo.cn/hotel/#{row[4]}.html"
      end
    end

  end

  desc "初始化去哪儿酒店信息爬取"
  task :init_qunar_price => :environment do

    result = Typhoeus.get("http://www.fishtrip.cn/channel_api/houses/qunar")
    next unless result.success?

    result_json = JSON.parse(result.body)
    next unless result_json

    Task.transaction do
      result_json.each do |n|
        result = n['channel_resource_id'].match(/([\s\S]+)_([0-9]+)/)

        (Time.now.tomorrow.to_date..50.day.since.to_date).each do |day|
          task_info = {
            url: "http://hotel.qunar.com/city/#{result[1]}/dt-#{result[2]}/?#fromDate=#{day.to_s}&toDate=#{day.next_day.to_s}",
            project: 'kancho',
              category: 'normal',
              script_name: 'kancho/kancho_casperjs_qunar.js',
              context: '',
          }

          Task.create!(task_info)
        end
      end
    end
  end
end
