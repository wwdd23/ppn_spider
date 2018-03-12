#!/usr/bin/env nodejs

var $ = require('cheerio');
var request = require('request');
var fs = require('fs');

var url = process.argv[2] || 'http://dev.kuaidaili.com/api/getproxy/?orderid=929249963707415&num=100&b_pcchrome=1&b_pcie=1&b_pcff=1&protocol=1&method=2&an_an=1&an_ha=1&format=json&sep=1';

var xhs_info = [];
request.get( { method: 'GET', url: url, gzip: true, timeout: 5 * 1000 } , function(error, response, body) {

  //    console.log("okokokkokoo")
  if (error && error.code === 'ETIMEDOUT') {
    process.exit(0);
    return;
  }

  if(response.statusCode != 200) {
    process.exit(0);
    return;
  }

  //$ = $.load(body);

  
 // var api_info = body.match(/\{.*\}/)[0];//去除前后多余字段

  var obj = JSON.parse(body); //将提取出来的内容转换为json格式

  var data = obj.data;

  console.log(data);
  res = [];
  data.proxy_list.forEach(function(n){ 
    str = n.split(":");
    
    res.push({
      ip: str[0],
      port: str[1],
    })
    console.log(res)
  })
  console.log(JSON.stringify({'status': 200 , 'result': res})) ;
})

