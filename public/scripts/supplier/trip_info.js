#!/usr/bin/env node

var $ = require('cheerio');
var request = require('request');
var fs = require('fs');
var Iconv = require('iconv-lite');



// 连接字符串格式为mongodb://主机/数据库名
//exports.mongoose = mongoose;
//var iconv = require('iconv-lite');
var url = process.argv[2] || 'http://www.3atrip.com/qiyeguojia/xxl.asp?sshf=3023&gotopage=26'

// url area  https://fr.huangbaoche.com/reflash/cla/static_area.js?1475999177939   


header = {

  "Content-Type":"text/html",
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
  "Accept-Encoding":"gzip, deflate",
  "Accept-Language":"zh-CN,zh;q=0.8",
  'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.8.1.14) Gecko/20080404 (FoxPlus) Firefox/2.0.0.14',
  //  'Cookie': 'cla_sso_token=702a7a62cbd142e35843; login_name=%E9%AB%98%E4%BC%9A%E5%A8%9F; JSESSIONID=84123C258BC1CCD2274E4787117CDEF9; Hm_lvt_c01e035e5dc6df389fa1746afc9cf708=1475908244,1476020986; Hm_lpvt_c01e035e5dc6df389fa1746afc9cf708=1476027955'

}

request.get( { encoding: null, method: 'GET', url: url, gzip: true, timeout: 5 * 1000, } , function(error, response, body) {
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
  //$ = $.load(body);


  $ = $.load(Iconv.decode(body, 'gb2312'));



  var result = [];
  $('.list_gw').each(function(){
    var e_info = {
      "sex" : null,
      "nickname" : null,
      "lc" : null,
      "product" : null,
      "phone" : null,
      "mobile" : null,
      "fax" : null,
      "email" : null,
      "qq" : null,
    
    };
    e_info["name"] = $(this).find('a b').text();
      
    $(this).find('b').each(function(){
      //console.log($(this).text())
      var t = $(this).text();
      switch(t){
        case "性别：":
          e_info['sex'] = $(this).next().text().trim();
          break;
        case "昵称：":
          e_info['nickname'] = $(this).next().text();
          break;
        case "所在地区：":
          e_info['lc'] = $(this).next().text();
          break;
        case "主要产品：":
          e_info['product'] = $(this).next().text();
          break;
        case "电话：":
          e_info['phone'] = $(this).next().text();
          break;
        case "":
          e_info['mobile'] = $(this).next().text();
          break;
        case "传真：":
          e_info['fax'] = $(this).next().text();
          break;
        case "电子信箱：":
          e_info['email'] = $(this).next().text();
          break;
        case "Q Q：":
          e_info['qq'] = $(this).next().text();
          break;

      }
    })
    result.push(e_info)
  })


  console.log(JSON.stringify({'status': 200, 'result': result},undefined,3));
})

