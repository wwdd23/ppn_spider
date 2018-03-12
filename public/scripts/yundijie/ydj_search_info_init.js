#!/usr/bin/env node

var $ = require('cheerio');
var request = require('request');
var fs = require('fs');


// 连接字符串格式为mongodb://主机/数据库名
//exports.mongoose = mongoose;
//var iconv = require('iconv-lite');
var url = process.argv[2] || "https://www.yundijie.com/search/addresses?offset=0&limit=50&input=银座&cityId=217&location=35.549441,139.779791" 


// url area  https://fr.huangbaoche.com/reflash/cla/static_area.js?1475999177939   

var context = process.argv[3] || "{\"type\":\"pickup\",\"airportInfo\":{\"airportCode\":\"HND\",\"airportHotWeight\":0,\"airportId\":68,\"airportLocation\":\"35.549441,139.779791\",\"airportName\":\"羽田国际机场\",\"bannerSwitch\":1,\"isHotAirport\":0,\"landingVisaSwitch\":0,\"cityId\":217,\"location\":\"35.549441,139.779791\"},\"date\":\"2017-12-23\",\"place\":\"银座\",\"cookie\":\"from_url=http%253A%252F%252Fzuche.yundijie.com%252F%253Fpnid%253DD05521627; _ga=GA1.2.1764177166.1492073690; cla_pre_login_token=b1a32dd704814c1194602d3c1d0c7e8d; cla_sso_token=2da6d21110ec4e147d90; login_name=BDtest17; JSESSIONID=853AE6524565EA9036400391C4CFCFC4; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1493023245,1493104823,1493282673,1493693057; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1493880707\"}"

var info = JSON.parse(context)

var cookie = info.cookie

//console.log(cookie)

header = {

  "Content-Type":"application/json; charset=UTF-8",
  "Authorization":"Basic 6auY5Lya5aifOjEyMzQ1Ng==",
  "Accept": "application/json, text/javascript, */*; q=0.01",
  "Accept-Encoding":"gzip, deflate",
  "Accept-Language":"zh-CN,zh;q=0.8",
  'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.8.1.14) Gecko/20080404 (FoxPlus) Firefox/2.0.0.14',
  'Cookie': cookie
}

 request.get( { method: 'GET', url: encodeURI(url), headers: header,  gzip: true, timeout: 5 * 1000 } , function(error, response, body) {
   if (error && error.code ==='ETIMEDOUT') {
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
 
   
   var data_parse = JSON.parse(body);
  
   if (data_parse.data.count== 0 ){
     process.exit(0);
     return;
   }

   var pickup_info = JSON.parse(body)['data']['places'][1];
     //console.log(pickup_info);
   var pickup_location = String(pickup_info['placeLat']) + "," + String(pickup_info['placeLng'])
    
   // 插入到mongo表中
   //连接到表  
 //  console.log(JSON.stringify({"status": 200, "result": body },undefined,3));
   var send_context = {};
   var air = {
   
     "airportCode": info.airportInfo.airportCode,
     "airportHotWeight": info.airportInfo.airportHotWeight,
     "airportId": info.airportInfo.airportId,
     "airportLocation": info.airportInfo.airportLocation,
     "airportName": info.airportInfo.airportName,
     "bannerSwitch": info.airportInfo.bannerSwitch,
     "isHotAirport": info.airportInfo.isHotAirport,
     "landingVisaSwitch": info.airportInfo.landingVisaSwitch,
     "cityId": info.airportInfo.cityId,
     "location": info.airportInfo.airportLocation,
   }
   send_context = {
     "post_info": {
       "airportCode": info.airportInfo.airportCode,
       "startLocation": info.airportInfo.airportLocation,
       "endLocation": pickup_location,
       "serviceDate": info.date + "  09:00:00",
       "startDate": info.date,
       "startTime": "09:00",
       "flightInfo": {
         "is_custom": 1
       },
       "airportInfo" : air,
       "pickupAddress": pickup_info,
     },
     "type": info.type,
   }

   //console.log(send_context)
   task = [];
   task.push({
     "url" : cookie,
     "project" : 'yundijie',
     "category": 'normal',
     "script_name" : 'yundijie/ydj_pickup.js',
     "context" : JSON.stringify(send_context), 

   });

   console.log(JSON.stringify({"status": 200, "task": task, "result": {}},undefined,3));


 })
