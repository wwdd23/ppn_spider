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

//var params = process.argv[2] || {"airportCode":"MEL","startLocation":"-37.8256591,144.9565805","endLocation":"-37.6733017,144.8430023","serviceDate":"2017-05-12 08:00:00","assitCheckIn":1,"airportInfo":{"airportCode":"MEL","airportHotWeight":0,"airportId":717,"airportLocation":"-37.6733017,144.8430023","airportName":"墨尔本国际机场（图拉马莱恩机场）","bannerSwitch":1,"isHotAirport":0,"landingVisaSwitch":0,"cityId":3,"location":"-37.6733017,144.8430023"},"transferAddress":{"placeAddress":"Normanby Road, South Melbourne VIC 3205澳大利亚","placeIcon":"https://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png","placeId":"ChIJdwyjPVRd1moRgciHtl4goes","placeLat":-37.8256591,"placeLng":144.9565805,"placeName":"The Colonial Tramcar Restaurant","score":0.0032917894423007965,"source":"google"},"startDate":"2017-05-12","startTime":"08:00"}



var url = process.argv[2] || "https://www.yundijie.com/search/byinitial?initials=A&serviceType=3"
var cookie = process.argv[3] ||"from_url=http%253A%252F%252Fzuche.yundijie.com%252F%253Fpnid%253DD05521627; _ga=GA1.2.1764177166.1492073690; cla_pre_login_token=24caf347edba4d109c47a38adf3f6c53; cla_sso_token=e797687135ac4d13e876; login_name=BDtest17; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1492744684,1492745916,1493023245,1493104823; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1493106202; JSESSIONID=880B877EAF7E80682DA3CFDCAD9FAC6D"

var header = {
	"Content-Type":"application/json; charset=UTF-8",
	"Authorization":"Basic 6auY5Lya5aifOjEyMzQ1Ng==",
	"Accept":"application/json, text/javascript, */*; q=0.01",
//	"Accept-Encoding":"gzip, deflate",
	"Accept-Language":"zh-CN,zh;q=0.8",
	"User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.8.1.14) Gecko/20080404 (FoxPlus) Firefox/2.0.0.14",
	//"User-Agent": ua,
	"Cookie": cookie, 
}

request.get({url:url,  headers: header},function(error, response, body) {
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

  res = JSON.parse(body)["data"]


  //console.log(JSON.stringify({"status": 200, "result": JSON.parse(body)},undefined,3));
  console.log(JSON.stringify({"status": 200, "result": res},undefined,3));
})
