#!/usr/bin/env nodejs

var $ = require('cheerio');
var request = require('request');
var fs = require('fs');

var url = process.argv[2] || 'http://www.xiaohongshu.com/api/discovery/list2?&_r=1490062859642&start=58afc75cb46c5d77d06c4438&num=200&oid=category.52ce1c02b4c4d649b58b892c';

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
  var api_info = body.match(/\{.*\}/)[0];//去除前后多余字段

  var obj = JSON.parse(api_info); //将提取出来的内容转换为json格式


  // console.log(JSON.stringify(obj,undefined,3));

  var data = obj.array;
//  console.log(data.length);
  for (var i = 0 ; i< data.length ; i++) {

    var tags = [];

    
    for (var m = 0 ; m< data[i].tags.length ; m++) {
      tags.push(data[i].tags[m].name);
    }

    //console.log(data[i].tags);

    xhs_info.push({
      "title": data[i].title,
      "name": data[i].name,
      "imageb": data[i].imageb,
      "images": data[i].images,
      "likes" : data[i].likes,
      "desc" : data[i].desc,
      "tags" : tags,
    });
  };
  console.log(JSON.stringify({'status': 200 , 'result': xhs_info})) ;
})

