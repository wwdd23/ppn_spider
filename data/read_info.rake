[["FCO", "Radisson Blu es. Hotel, Rome:",["2017-06-15", "2017-08-15", "2017-10-20", "2017-11-02"]],
["FCO", "Rome Marriott Park Hotel",["2017-06-15", "2017-08-15", "2017-10-20", "2017-11-02"]],
["FCO", "Best Western CineMusic Hotel",["2017-06-15", "2017-08-15", "2017-10-20", "2017-11-02"]],
["FCO", "Hotel ibis Styles Roma Eur",["2017-06-15", "2017-08-15", "2017-10-20", "2017-11-02"]],
["FCO", "Quality Hotel 罗马罗吉安诺酒店",["2017-06-15", "2017-08-15", "2017-10-20", "2017-11-02"]],]


  out = [["date", "type","airport", "airportcode", "location", "address", "childSeatPrice1", "childSeatPrice2", "pickupSignPrice",
          "distance", "supportBanner", "supportChildseat",
          "capOfLuggage", "capOfPerson", "carDesc", "carId", "carIntroduction", "carType", 
          "currency", "currencyRate", "localPrice", "models", "originPrice", "overChargePerHour", "payDeadline", 
          "price", "seatCategory", "seatType", "special", "urgentCutdownTip", "urgentFlag",
  ]]

$mongo_qspider['ydj_pickup.js'].find(:"context.post_info.airportInfo.airportCode" => "FCO").each do |n|

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

Emailer.send_custom_file(['diaoxu@haihuilai.com', 'chenyilin@haihuilai.com'],  "云地接意大利接机数据", XlsGen.gen(out), "意大利接机数据.xls" ).deliver
