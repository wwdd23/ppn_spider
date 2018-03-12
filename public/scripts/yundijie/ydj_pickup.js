#!/usr/bin/env nodejs
//jalan 日本页面信息抓取脚本
//前序任务  jalan_list.js
//

var $ = require("cheerio");
var request = require("request");
var fs = require("fs");
//var iconv = require("iconv-lite");
var zlib = require('zlib');

//iconv.extendNodeEncodings();


//var url = process.argv[2] || "https://www.yundijie.com/price/batchPrice"
var url = "https://www.yundijie.com/price/query_pickup_quotes"
var cookie = process.argv[2] || "from_url=http%253A%252F%252Fzuche.yundijie.com%252F%253Fpnid%253DD05521627; _ga=GA1.2.1764177166.1492073690; cla_pre_login_token=b1a32dd704814c1194602d3c1d0c7e8d; cla_sso_token=e4569f05e22843848b31; login_name=BDtest17; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1493023245,1493104823,1493282673,1493693057; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1493795307; JSESSIONID=290EDF8BA4BA2B9E5404C5BB618984BE" 

var params = process.argv[3] || "{\"airportCode\":\"BKK\",\"startLocation\":\"13.689999,100.750112\",\"endLocation\":\"13.7407451,100.5586429\",\"serviceDate\":\"2017-05-12 08:00:00\",\"startDate\":\"2017-05-12\",\"startTime\":\"08:00\",\"flightInfo\":{\"is_custom\":1},\"airportInfo\":{\"airportCode\":\"BKK\",\"airportHotWeight\":0,\"airportId\":25,\"airportLocation\":\"13.689999,100.750112\",\"airportName\":\"素万那普国际机场\",\"bannerSwitch\":1,\"isHotAirport\":1,\"landingVisaSwitch\":0,\"cityId\":230,\"location\":\"13.689999,100.750112\"},\"pickupAddress\":{\"placeAddress\":\"10 Sukhumvit Soi 15, Sukhumvit 15 Alley, Klongtoey Nua, Wattana, Bangkok 10110泰国\",\"placeIcon\":\"https://maps.gstatic.com/mapfiles/place_api/icons/lodging-71.png\",\"placeId\":\"ChIJW3-qd-ae4jAR_lOtKTIfG7A\",\"placeLat\":13.7407451,\"placeLng\":100.5586429,\"placeName\":\"Dream Hotel\",\"score\":0.2712774872779846,\"source\":\"google\"}}"

var info = JSON.parse(params);

var type = info.type

if (type == "pickup") {var url = "https://www.yundijie.com/price/query_pickup_quotes"}
if (type == "transfer") {var url = "https://www.yundijie.com/price/query_transfer_quotes"}

var header = {
  "Content-Type":"application/json; charset=UTF-8",
  "Authorization":"Basic 6auY5Lya5aifOjEyMzQ1Ng==",
  "Accept":"application/json, text/javascript, */*; q=0.01",
  "Accept-Language":"zh-CN,zh;q=0.8",
  "Cookie": cookie,
}


send = JSON.stringify(info.post_info);

//console.log(send);
request.post({url: url,  headers: header, body: send},function(error, response, body) {
  //request.get({url:url, headers: header , encoding:null },function(error, response, body) {
  if (error && error.code ==="ETIMEDOUT") {
    process.exit(0);
    return;
  }
  if(response == null) {
    process.exit(0);
    return;
  }
  if(response.statusCode != 200) {
    process.exit(0);
    return;
  }

  encoding = response.headers['content-encoding'];
  //console.log(encoding);

  data = JSON.parse(body.toString());

  console.log(JSON.stringify({"status": 200, "result": data["data"] },undefined,3));
})
