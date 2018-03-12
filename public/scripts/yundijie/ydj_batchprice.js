#!/usr/bin/env nodejs
//

var $ = require("cheerio");
var request = require("request");
var fs = require("fs");
//var iconv = require("iconv-lite");
var zlib = require('zlib');

//iconv.extendNodeEncodings();


//var url = process.argv[2] || "https://www.yundijie.com/price/batchPrice"
var url = process.argv[2] || "https://www.yundijie.com/price/batchPrice"

var params = process.argv[3] || "{\"locations\":\"9.5011335,100.0014125\",\"city_id\":234,\"start_date\":\"2017-07-08 09:00:00\",\"end_date\":\"2017-07-08 23:59:59\",\"cookie\":\"_ga=GA1.2.1764177166.1492073690; cla_pre_login_token=50b5f971f1334504a44d7e0485ec80ea; cla_sso_token=71e9f086d97b411dbd81; login_name=BDtest17; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1492745916,1493023245,1493104823,1493282673; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1493352207; JSESSIONID=591B8B4F34486B2F498AC8DD7071FBC\"}"

var info = JSON.parse(params)
var cookie = info["cookie"]
var locations = info["locations"]
var city_id = info["city_id"]
var start_date = info["start_date"]
var end_date = info["end_date"]
var type = info["type"]


if (type == "in_city"){
  var t = 1
} else if (type == "out_city"){
  var t = 2
}



var post_data = {"batchPrice": [{"serviceType": 3,"param": {"specialCarsIncluded": 1,"endCityId":city_id,"startLocation":locations,"startCityId":city_id,"endDate":end_date,"halfDay": 0,"channelId":"1101428796","endLocation":locations,"startDate":start_date,"passCities": (city_id + "-1-" + t)},"index": 1}]}

var header = {
	"Content-Type":"application/json; charset=UTF-8",
	"Authorization":"Basic 6auY5Lya5aifOjEyMzQ1Ng==",
	"Accept":"application/json, text/javascript, */*; q=0.01",
	"Accept-Language":"zh-CN,zh;q=0.8",
  "Cookie": cookie,
}


 request.post({url: url,  headers: header, body: JSON.stringify(post_data)},function(error, response, body) {
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
 
   data = JSON.parse(body.toString());
 
   console.log(JSON.stringify({"status": 200, "result": {"data": data["data"] ,"type" : type },undefined,3));
 })
