#!/usr/bin/env nodejs

//获取供应商团队直连住宿备选名单
//抓取mfw 韩国住宿房间数量详情

var $ = require('cheerio');
var request = require('request');
var fs = require('fs'); 
var url = process.argv[2] || 'https://publicholidays.global/' 
//var url = process.argv[2] || 'http://stay.visitseoul.net/ck/sub_view.html?fmuid=615&pcate=3&pn=1' 

request.get(url , function(error, response, body) {
  if(error && error.code === 'ETIMEDOUT') {
    process.exit(0);
    return;
  }
  if( response == null) {
    process.exit(0);
    return;
  }

  if(response.statusCode != 200) {
    process.exit(0);
    return;
  }

  var result = {};

  $ = $.load(body);
  var task = []
  var cn_list = ["China", "Hong Kong", "Singapore", "Malaysia", "Taiwan" ]
  var jp_list = ["Japan"]
  $('tbody').each(function(){
    $(this).find("td").each(function() {
      var url = $(this).find('a').attr("href");
      country = $(this).find('a').text();

      if (cn_list.includes(country) ){
      
        s_url = url + "zh/2018-dates/"
        
      }else if(jp_list.includes(country)) {
        s_url = url + "ja/2018-dates/"
      }else {
        s_url = url + "2018-dates/"
      }

      if (url != undefined) {
        task.push({ 
          'url' : s_url,
          'project' : 'publicholiday',
          'category': 'normal',
          'script_name': "publicholiday/get_holiday.js",
          'context':  JSON.stringify({"country": country }),
        });
      }
    })
  })

  console.log(JSON.stringify({'status': 200,  'result': {}, 'task': task},undefined,3));


})
