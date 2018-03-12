#!/usr/bin/env nodejs

var $ = require('cheerio');
var request = require('request');
var fs = require('fs'); 
var url = process.argv[2] || 'https://publicholidays.asia/thailand/2018-dates/' 
//var url = process.argv[2] || 'http://stay.visitseoul.net/ck/sub_view.html?fmuid=615&pcate=3&pn=1' 
var context = process.argv[3] || '{"country": "thailand"}'

var task_context = JSON.parse(context);

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

  var result = {"data" : [], "country" : task_context["country"]};

  $ = $.load(body);



  $('.publicholidays.phgtable ').find('tbody tr').each(function(){

    var t = []
    $(this).find('td').eq(0).find('time').each(function(){
      t.push($(this).attr('datetime'))
    })
    var day = $(this).find('td').eq(1).text()
    var holiday = $(this).find('td').eq(2).text()
    var state = $(this).find('td').eq(3).text()
    result['data'].push({
      "time" : t,
      "day" : day,
      "holiday" : holiday,
      "state" : state,
    })
  })
  console.log(JSON.stringify({'status': 200,  'result': result, },undefined,3));
})
