#!/usr/bin/env node

var $ = require('cheerio');
var request = require('request');
var fs = require('fs');


// 连接字符串格式为mongodb://主机/数据库名
//exports.mongoose = mongoose;
//var iconv = require('iconv-lite');
var url = process.argv[2] || 'http://www.3atrip.com/qiye.asp'

// url area  https://fr.huangbaoche.com/reflash/cla/static_area.js?1475999177939   


header = {

  "Content-Type":"application/json; charset=UTF-8",
  "Authorization":"Basic 6auY5Lya5aifOjEyMzQ1Ng==",
  "Accept": "application/json, text/javascript, */*; q=0.01",
  "Accept-Encoding":"gzip, deflate",
  "Accept-Language":"zh-CN,zh;q=0.8",
  'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.8.1.14) Gecko/20080404 (FoxPlus) Firefox/2.0.0.14',
  //  'Cookie': 'cla_sso_token=702a7a62cbd142e35843; login_name=%E9%AB%98%E4%BC%9A%E5%A8%9F; JSESSIONID=84123C258BC1CCD2274E4787117CDEF9; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1475908244,1476020986; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1476027955'

}

request.get( { method: 'GET', url: url, gzip: true, timeout: 5 * 1000 } , function(error, response, body) {
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

  var task = [];
  $ = $.load(body);
  $(".qiye4").each(function(){
    var url = $(this).find('a').attr('href');
    task.push({
      'url' : 'http://www.3atrip.com/' + url,
      'project' : 'supplier',
      'category': 'normal',
      'script_name': 'supplier/trip_list.js',
      'context': '',
    });
  })

  console.log(JSON.stringify({'status': 200, 'task':task, 'result': {}},undefined,3));
})



// task_info = {
//   url: ,
//   project:'yundijie',
//   category: 'normal',
//   script_name: 'yundijie/ydj_location.js',
//   context: cookie,
// 
// }
