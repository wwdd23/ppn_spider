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

var params = process.argv[2] ||{"batchPrice":[{"serviceType":3,"param":{"specialCarsIncluded":1,"endCityId":163,"startLocation":"47.368736,8.544955","startCityId":163,"endDate":"2017-05-30 23:59:59","halfDay":0,"channelId":"1101428796","endLocation":"47.368736,8.544955","startDate":"2017-05-30 09:00:00","passCities":"163-1-1"},"index":1}]}


var header = {
	"Content-Type":"application/json; charset=UTF-8",
	"Authorization":"Basic 6auY5Lya5aifOjEyMzQ1Ng==",
	"Accept":"application/json, text/javascript, */*; q=0.01",
//	"Accept-Encoding":"gzip, deflate",
	"Accept-Language":"zh-CN,zh;q=0.8",
	"User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.8.1.14) Gecko/20080404 (FoxPlus) Firefox/2.0.0.14",
	//"User-Agent": ua,
	"Cookie": "from_url=http%253A%252F%252Fzuche.yundijie.com%252F%253Fpnid%253DD05521627; _ga=GA1.2.1764177166.1492073690; cla_pre_login_token=4749710b1270417991bbd75231eb0a9b; cla_sso_token=3f6ee39763f848a8ac70; login_name=BDtest17; JSESSIONID=3243D321D2F8D9BC37793F02E84D228D; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1492656768,1492744684,1492745916,1493023245; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1493083582"
}

var post_url = "https://www.yundijie.com/price/batchPrice"

request.post({url:post_url,  headers: header, body: JSON.stringify(params)},function(error, response, body) {
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

				
  //console.log(body.toString())



	//console.log(body);
	  console.log(JSON.stringify({"status": 200, "result": JSON.parse(body.toString())},undefined,3));
})
