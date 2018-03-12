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
    var count = $('.sr_header').text();
    var items = $(".sr_item");

    var task = [];

    $(".sr_item_new").each(function(){
      var url = ($(this).find('.address a').attr('href').match(/(hotel\/jp.*html)/)[1]);
      var data_coords = ($(this).find('.address a').attr('data-coords').split(","));

      data = ({
        "lng": data_coords[0],
        "lat": data_coords[1],
      })

      var post_url = "https://www.booking.com/" + url;
      task.push({
        'url' : post_url,
        "project" : 'casper_booking',
        "category" : 'normal',
        "script_name" : 'casper_booking/booking_info.js',
        "context" :  JSON.stringify(data),
      });

    });
    return task;
  });
  console.log(JSON.stringify({'status': 200, 'task': result, 'result': {}},undefined,3));
},  1000 * 50);
casper.run();
