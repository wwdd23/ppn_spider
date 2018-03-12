# encoding: utf-8
require 'csv'

namespace :create_ydj do




  desc "供应商抓取数据信息报表"
  task :supplier_task  => :environment do 
    Task.transaction do
      url = 'http://www.3atrip.com/qiye.asp'
      task_info = {
        url: url,
        project:'supplier',
        category: 'normal',
        script_name: 'supplier/supplier_list.js',
        context: '',

      }
      Task.create!(task_info)
    end
  end



  desc "供应商抓取数据信息报表"
  task :supplier_report => :environment do 

    out =[["名称", "昵称", "主要产品", "性别", "电话", "手机", "传真", "邮箱", "地区", "qq"]]

    $mongo_qspider['trip_info.js'].find().each do |data|

      data["data"].each do |n|
        out << [n["name"], n["nickname"], n["product"], n["sex"], n["phone"], n["mobile"], n["fax"], n["email"], n["lc"], n["qq"]]
      end
    end


    Emailer.send_custom_file(['wudi@haihuilai.com'],  "供应商抓取基础数据", XlsGen.gen(out), "供应商抓取基础数据信息.xls", true ).deliver
  end




  desc "云地接接机/送机数据爬取"
  task :pickup => :environment do 

    cookie = ENV["cookie"]
    type = ENV["type"]
    
    if cookie == nil || type == nil
      Rails.logger.error "please enter rake create_ydj:pickup cookie=xxx type=pickup/transfer"
      p "please enter rake create_ydj:pickup cookie=xxx type=pickup/transfer"
      return
    end
    task_array = [
      ["SYD", "Four Seasons Hotel Sydney", ['2017-07-03', '2017-12-23'] ]
    ]
    Task.transaction do
      task_array.each do |n|
        n[2].each do |date|
        air = YdjAirport.where(:airportCode => n[0]).first
        airportInfo =  {
          "airportCode": air.airportCode,
          "airportHotWeight": air.airportHotWeight,
          "airportId": air.airportId,
          "airportLocation": air.airportLocation,
          "airportName": air.airportName,
          "bannerSwitch": air.bannerSwitch,
          "isHotAirport": air.isHotAirport,
          "landingVisaSwitch": air.landingVisaSwitch,
          "cityId": air.cityId,
          "location": air.airportLocation
        }
        url = "https://www.yundijie.com/search/addresses?offset=0&limit=50&input=" + n[1] + "&cityId=" +  air.cityId.to_s + "&location=" + air.airportLocation.to_s
        task_info = {
          url: url,
          project:'yundijie',
          category: 'normal',
          script_name: 'yundijie/ydj_search_info_init.js',
          context: {"type": type, "airportInfo": airportInfo, "date": date, "place": n[1], "cookie": cookie}.to_json,
        }
        p  task_info
        Task.create!(task_info)
        end
      end
    end
  end

  desc "云地接机场信息数据"
  task :get_airport => :environment do 
    Task.transaction do
      task_info = {
        url: "https://fr-static.huangbaoche.com/reflash/cla/city_airports.js",
        project:'yundijie',
        category: 'normal',
        script_name: 'yundijie/ydj_airport.js',
        context: "",
      }
      p  task_info
      Task.create!(task_info)

    end
  end

  desc "云地接一日包车任务"
  task :batch_price => :environment do


    cookie = ENV["cookie"]
    # type = ENV["type"] # in_city out_city


    if cookie == nil
      Rails.logger.error "please add cookie=xxxxx"
      p "forgot enter cookie=xxxx"
      return
    end

    #city_name = ["东京", "苏梅岛"]
    #city_name = ["东京", "苏梅岛", "芭堤雅", "巴黎", "巴厘岛"]
    # city_name = ["纽约","洛杉矶","台北","北海道--札幌","冲绳--那霸","首尔","墨尔本",]
    #city_name  = ["伦敦", "爱丁堡", "巴塞罗那", "马德里", "哥本哈根", "巴黎", "罗马", "布拉格", "大阪", "东京", "北海道--札幌", "京都", "曼谷", "清迈", "新加坡", "普吉岛", "迪拜"]
    #city_name = ["东京", "大阪", "北海道--札幌", '京都']
    #span = ["2017-12-24", "2017-10-20", "2018-01-23"]
    # city_name = ["曼谷", "清迈", "新加坡", '普吉岛']
    # span = ["2017-08-03", "2017-07-13", "2017-08-23"]
    #city_name = ["伦敦", "爱丁堡", "巴塞罗那", "马德里", "哥本哈根", "巴黎", "罗马", "布拉格",]
    #span = ["2017-06-20", "2017-07-10", "2017-08-23", "2017-06-28", "2017-09-08", "2018-01-05"]
    city_name = ["东京"]
    span = ["2017-11-25"]


    #未来8个月随机生成5个价格时间点
    #a = Time.now.to_date..(Time.now.to_date + 8.month)
    #span = []
    #5.times  do 
    #  span << rand(a).to_s
    #end

    Task.transaction do
      #["in_city", "out_city"].each do |type|
      ["in_city", "out_city"].each do |type|
        city_name.each do |city|
          span.each do |day|
            p city
            city_info = YdjPoi.where(:name => city).first
            p city_info
            city_id = city_info.cityId
            location = city_info.cityLocation
            start_day= (Time.parse(day) + 9.hour).strftime("%Y-%m-%d %H:%M:%S")
            end_day= Time.parse(day).end_of_day.strftime("%Y-%m-%d %H:%M:%S")
            #post_info = {:batchPrice => [{:serviceType => 3,:param => {:specialCarsIncluded => 1,:endCityId =>city_id,:startLocation =>location,:startCityId =>city_id,:endDate =>end_day,:halfDay => 0,:channelId =>1101428796,:endLocation =>location,:startDate =>start_day,:passCities => "#{city_id}-1-1",:index => 1}]}
            task_info = {
              url: "https://www.yundijie.com/api/price/v1.0/batchPrice",
              project:'yundijie',
              category: 'normal',
              script_name: 'yundijie/ydj_batchprice_v1.js',
              context: {:locations => location, :city_id => city_id, :start_date => start_day, :end_date => end_day, :cookie => cookie, :type => type}.to_json,
            }
            p  task_info
            Task.create!(task_info)
          end 
        end
      end
    end
  end

  desc "云地接地区信息"
  task :location => :environment do
    span = ('A'..'Z').to_a
    cookie = ENV["cookie"]
    if cookie == nil
      Rails.logger.error "please add cookie=xxxxx"
      return
    end
    Task.transaction do
      span.each do |n|
        url = "https://www.yundijie.com/search/byinitial?initials=#{n}&serviceType=3"
        task_info = {
          url: url,
          project:'yundijie',
          category: 'normal',
          script_name: 'yundijie/ydj_location.js',
          context: cookie,
        }
        p url
        Task.create!(task_info)
      end
    end
  end


  desc "一日包车数据整理"
  task :daily_report => :environment do
    send = [['城市ID', '城市', '类型', '服务日期', '车型', '车辆种类', '座位数', '人数', '行李数', '行程总价(当地货币)', '人民币价', '币种', '空置费用(当地)', '汇率', '当地单价', '等待费',  '餐费', '导游类型', '特殊服务状态', ]]
    # $mongo_qspider['ydj_batchprice.js'].find(:created_at => {:$gte => Time.parse(Time.now.to_date.to_s)}, :"context.type" => "in_city").count

    $mongo_qspider['ydj_batchprice.js'].find(:created_at => {:$gte => Time.parse(Time.now.to_date.to_s)}).each do |n|
      base = n['data']
      #childprice1 = base['dailyAdditionalServicePrice']['childSeatPrice1'].present? ? base['dailyAdditionalServicePrice']['childSeatPrice1'] : 0
      #childprice2 = base['dailyAdditionalServicePrice']['childSeatPrice2'].present? ? base['dailyAdditionalServicePrice']['childSeatPrice2'] : 0

      noneCarsParam = base["noneCarsParam"]
      noneCarsReason = base ["noneCarsReason"]
      noneCarsState = base["noneCarsState"]
      serviceDate = n['context']["start_date"]
      spider_type = n['context']['type']

      quoteinfo = base['quoteInfos']

      quoteinfo.each do |info|
        capOfLuggage = info['capOfLuggage']
        capOfPerson = info['capOfPerson']
        carDesc = info['carDesc']
        carIntroduction = info['carIntroduction']
        models = info['models']
        price = info['price']
        priceWithAddition = info['priceWithAddition']
        quotes = info['quotes']
        additionalServicePrice = quotes.first['additionalServicePrice']
        currency = quotes.first['currency']
        currencyRate = quotes.first['currencyRate']
        dayOriginPrice = quotes.first['dayOriginPrices'].first['dayOriginPrice']
        dayOriginPrices_day = quotes.first['dayOriginPrices'].first['day']
        emptyOriginPrice = quotes.first['emptyOriginPrice']
        index = quotes.first['index']
        mealDays= quotes.first['mealDays']
        mealPrice = quotes.first['mealPrice']
        originPrice = quotes.first['originPrice']
        originPriceWithAddition = quotes.first['originPriceWithAddition']
        quotes_price = quotes.first['price']
        quotes_priceWithAddition = quotes.first['priceWithAddition']
        quoteCityId = quotes.first["quoteCityId"]
        quoteCityName = quotes.first['quoteCityName']
        serviceType = quotes.first['serviceType']
        stayPrice = quotes.first['stayPrice']
        seatCategory = info['seatCategory']
        seatType = info['seatType']
        serviceTags = info['serviceTags']
        urgentCutdownTip = info['urgentCutdownTip']
        urgentFlag = info['urgentFlag']
        special = info['special']

        send << [ quoteCityId, quoteCityName, spider_type, serviceDate, carDesc, models, seatType, capOfPerson, capOfLuggage, dayOriginPrice, price, currency, emptyOriginPrice, currencyRate, originPrice, stayPrice, mealPrice, serviceTags, special ] 
      end
    end
    Emailer.send_custom_file(['wudi@haihuilai.com'],  "云地接一日包车数据抓取", XlsGen.gen(send), "云地接一日包车数据抓取数据.xls" ).deliver
  end

  desc "接送机数据整理"
  task :pickup_report => :environment do


    start_day = (ENV['start_day'] || Time.now.to_date.to_s)
    end_day = (ENV['end_day'] || Time.now.to_date.to_s)

    out = [["date", "type" ,"airport", "airportcode", "location", "address", "childSeatPrice1", "childSeatPrice2", "pickupSignPrice",
            "distance", "supportBanner", "supportChildseat",
            "capOfLuggage", "capOfPerson", "carDesc", "carId", "carIntroduction", "carType",
            "currency", "currencyRate", "localPrice", "models", "originPrice", "overChargePerHour", "payDeadline",
            "price", "seatCategory", "seatType", "special", "urgentCutdownTip", "urgentFlag",
    ]]

    #$mongo_qspider['ydj_pickup.js'].find(:"context.post_info.airportInfo.airportCode" => "FCO").each do |n|
    $mongo_qspider['ydj_pickup.js'].find(:created_at => {:$gte => Time.parse(start_day).beginning_of_day,:$lte => Time.parse(end_day).end_of_day}).each do |n|

      post_info = n["context"]["post_info"]
      type = n["context"]["type"]
      air_info = post_info["airportInfo"]
      address_info = post_info["pickupAddress"]
      data_base = n["data"]
      airportCode = air_info["airportCode"]
      airportName = air_info["airportName"]
      placeName = address_info['placeName']
      placeAddress = address_info['placeAddress']
      additionalServicePrice = data_base['additionalServicePrice']
      childSeatPrice1 = additionalServicePrice["childSeatPrice1"]
      childSeatPrice2 = additionalServicePrice["childSeatPrice2"]
      pickupSignPrice = additionalServicePrice["pickupSignPrice"]
      distance = data_base["distance"]
      supportBanner = data_base["supportBanner"]
      supportChildseat = data_base["supportChildseat"]
      cars = data_base["cars"]
      startDate = post_info["startDate"]
      cars.each do |n|
        out << [
          startDate, type,
          airportName, airportCode, placeName, placeAddress, childSeatPrice1, childSeatPrice2, pickupSignPrice, 
          distance, supportBanner , supportChildseat,
          n["capOfLuggage"], n["capOfPerson"], n["carDesc"], n["carId"], n["carIntroduction"], n["carType"],
          n["currency"], n["currencyRate"], n["localPrice"], n["models"], n["originPrice"], n["overChargePerHour"], n["payDeadline"], 
          n["price"], n["seatCategory"], n["seatType"], n["special"], n["urgentCutdownTip"], n["urgentFlag"]
        ]
      end
    end

    #Emailer.send_custom_file(['diaoxu@haihuilai.com', 'chenyilin@haihuilai.com'],  "云地接#{start_day}接送机数据", XlsGen.gen(out), "云地接#{start_day}接送机数据.xls" ).deliver
    Emailer.send_custom_file(['wudi@haihuilai.com'],  "云地接#{start_day}接送机数据", XlsGen.gen(out), "云地接#{start_day}接送机数据.xls" ).deliver

  end

end
