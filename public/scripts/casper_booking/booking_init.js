#!/usr/bin/env casperjs
// /kancho_ctrip_address.js 'http://hotels.ctrip.com/hotel/735554.html'
// 信息内容包含 酒店id 酒店名称 城市 区  地址  商圈范围
var casper = require('casper').create({
  pageSettings: {
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0",
    "loadImages": false,
  }
});

var url = casper.cli.args[0] || 'https://www.booking.com/searchresults.zh-cn.html?aid=304142&label=gen173nr-1DCAEoggJCAlhYSDNiBW5vcmVmaDGIAQGYATK4AQfIAQzYAQPoAQGSAgF5qAID&sid=9b04114cc225ce6fc8e4d1ca0cc90f11&checkin_month=5&checkin_monthday=17&checkin_year=2017&checkout_month=5&checkout_monthday=18&checkout_year=2017&class_interval=1&dest_id=106&dest_type=country&dtdisc=0&group_adults=2&group_children=0&inac=0&index_postcard=0&label_click=undef&mih=0&no_rooms=1&postcard=0&raw_dest_type=country&room1=A%2CA&sb_price_type=total&src=index&src_elem=sb&ss=%E6%97%A5%E6%9C%AC&ss_all=0&ssb=empty&sshis=0&rows=15&offset=60'

var debug = require('system').env['DEBUG'] == "true"
if (debug){
  casper.on('remote.message', function(msg) {
    this.echo(msg);
  })

  casper.on('page.error', function(msg) {
    this.echo(msg);
  })
}

casper.on('resource.requested', function(requestData, request){
  if (requestData.url.match(/google|gstatic|doubleclick/)){
    request.abort();
    return;
  }
})

casper.start(url).waitFor(function(){
  return this.evaluate(function(){
    //return $(".txt_taxtips").length > 0;
    return $(".sr_header").length > 0;
  })
}, function() {
  var result = this.evaluate(function(){
    var page = parseInt($('.sr_pagination_item').last().text());
    var task = [];
    var url = "https://www.booking.com/searchresults.zh-cn.html?&checkin_month=4&checkin_monthday=23&checkin_year=2017&checkout_month=4&checkout_monthday=25&checkout_year=2017&class_interval=1&dest_id=106&dest_type=country&group_adults=2&group_children=0&label_click=undef&mih=0&no_rooms=1&raw_dest_type=country&room1=A%2CA&sb_price_type=total&src=searchresults&src_elem=sb&ss=日本&ssb=empty&ssne=日本&ssne_untouched=日本&rows=15&"
      for(i = 0; i < page; i++) {
        console.log(i);
      task.push({

        'url' :  url + "offset=" + (i*15),
        "project" : 'casper_booking',
        "category" : 'normal',
        "script_name" : 'casper_booking/booking_list_task.js',
        "context" :  "",
      });
    }
    return task;
  });
  console.log(JSON.stringify({'status': 200, 'task': result, 'result': {}},undefined,3));
},  1000 * 50);
casper.run();
