#!/usr/bin/env casperjs
// /kancho_ctrip_address.js 'http://hotels.ctrip.com/hotel/735554.html'
// 信息内容包含 酒店id 酒店名称 城市 区  地址  商圈范围
var casper = require('casper').create({
  pageSettings: {
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0",
    "loadImages": false,
  }
});

var url = casper.cli.args[0] || 'https://www.booking.com/hotel/jp/ryokan-wakaba.zh-cn.html?aid=304142;'


var context = casper.cli.args[1] || "{\"lng\":\"135.774355083704\",\"lat\":\"34.9986020924275\"}" 

var parse_context = JSON.parse(context);

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
  //casper.capture("comp.png");
  return this.evaluate(function(){
      $('#close_map_lightbox').click();
    //return $(".hp__hotel-name").length > 0;
    return $("#hp_hotel_name").length > 0;
    //return $(".hotel_thumbs_sprite").length > 0;
    //return $('script[type="application/ld+json"]').length > 0;
  })
}, function() {
  var res = casper.evaluate(function(parse_context){
    //var name = $('.hp__hotel-name').text().trim();
    var name = $('#hp_hotel_name').text().trim();
    var address = $('.hp_address_subtitle').text().trim();

    
    console.log(name);
    console.log(address);
    var airport_info = []
    $('.poi-list-header').each(function(){
      var list_name = $(this).text().trim();
       if( list_name == "邻近机场") {
         $(this).parent().each(function(){
           $(this).find('.poi-list-item').each(function(){
             var airport = $(this).find('.poi-list-item__title').text().trim().replace("\n","");
             //var airport = $(this).find('.poi-list-item__title').text().trim();
             var distanc = $(this).find('.poi-list-item__distance').text().trim();
             //console.log(airport);
             //console.log(distanc);
             airport_info.push({
               "airport": airport,
               //"airportcode": airport[1].match(/\((.*)\)/)[1],
               //"airportcode": airport[1],
               "distanc": distanc,
             })
           })
         });
       }
    })
    var json_info = $('script[type="application/ld+json"]').text().trim();

    var parse_json = JSON.parse(json_info);

    console.log(json_info);

    out = {}
    out['airport'] = airport_info;
    out['hotel'] = name;
    out['address'] = address;
    out['address_en'] = parse_json["address"]["addressLocality"];
    out['addressRegion'] = parse_json["address"]["addressRegion"];
    out['addressCountry'] = parse_json["address"]["addressCountry"];
    out['name_cn'] = parse_json["name"];
    out['type'] = parse_json["@type"];
    out['url'] = parse_json["url"];
    out["lng"] = parse_context['lng']
    out["lat"] = parse_context['lat']

      return out;
  },parse_context);
  //casper.capture("comp2.png");
  console.log(JSON.stringify({'status': 200, 'result': res},undefined,3));
},  1000 * 70);
casper.run();
