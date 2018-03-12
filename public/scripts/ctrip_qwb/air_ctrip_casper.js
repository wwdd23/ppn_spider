#!/usr/bin/env casperjs

var casper = require('casper').create({
  //  clientScripts: ["jquery.min.js"],
  pageSettings: {
 //   "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
    "loadImages": false, //不加载图片
    "loadPlugins": false, 
    //"proxy": "91.73.131.254:8080",
  }
});

var url = casper.cli.args[0] || 'http://car.ctrip.com/hwdaijia/list?ptType=17&cid=228&useDt=2017-04-25%2014:40&flNo=&dptDt=&locNm=%E6%88%90%E7%94%B0%E6%9C%BA%E5%9C%BA&locCd=NRT&locType=1&locSubCd=&locSubType=1&poiCd=926340&poiType=2&poiNm=%E5%8D%83%E5%8F%B6%E4%B8%9C%E4%BA%AC%E6%B9%BE%E5%B8%8C%E5%B0%94%E9%A1%BF%E9%85%92%E5%BA%97(Hilton%20Tokyo%20Bay%20Chiba)&poiAddr=1-8%2C%20Maihama%2C%20rayasu-shi&poiLng=139.87366&poiLat=35.62795';
//var context = casper.cli.args[1] || '{ "start_day": "2016-01-01", "end_day": "2016-01-02"}';

city = url.match(/cid=([0-9]+)/)[1];
date = url.match(/useDt=([0-9]+-[0-9]+-[0-9]+)/)[1];
time = url.match(/useDt.*%20([0-9]+:[0-9]+)&fl/)[1];
airportCode = url.match(/locCd=(\w+)&/)[1];
type = url.match(/ptType=([0-9+])/)[1];

/*
casper.on('remote.message', function(msg) {
  this.echo(msg);
})

casper.on('page.error', function(msg) {
  this.echo(msg);
})
*/

casper.on('resource.requested', function(requestData, request){
  if (requestData.url.match(/google|gstatic|doubleclick/)){
    request.abort();
    return;
  }
})


function click() {
  casper.evaluate(function() {
    $('.lg_btn2').click();
  })
}
casper.start(url).thenClick('a.lg_btn2', function(){
  //this.echo("click lg_btn2");
})
casper.waitFor(function(){

//  if ( (new Date() * 1 - begin_time) < 1000 * 90){
//    console.log("waiting");
//    return false;
//  };

  return this.evaluate(function(){
    //return $(".txt_taxtips").length > 0;
    return $('.cl_type').length > 0
    //return $('.cl_list').length != 0
    //return $('.cl_tab').length != 0
  })
}, function(){
  // this.capture('comp2.png');
  var result = this.evaluate(function(city, date, time, airportCode, type){
    var info = []
    // 最低价位置内容
    $('div.cl_type').each(function() {
      var passenger = $(this).find('big .passenger').next().text();
      var baggager = $(this).find('.baggage').next().text();
      var all_big = $(this).text().replace(/\s/g,"");
      var spl = all_big.split(passenger + baggager)[0];
      var price = $(this).find('.type_price big').text();
      var num = $(this).find('.type_price .num').text();

      // 每个车型价格表
      var res = [];
      $(this).next().find('.bb').each(function() {
        var supply = $(this).find('.supply').text().replace(/\s/g,"");
        var service = [];
        $(this).find('.service em').each(function() {
          service.push($(this).text().trim().replace(/\s/g,","));
        });
        var score  = $(this).find('.score big').text();
        var sprice = $(this).find('.prix big').text();
        res.push ({
          "supply" : supply,
          "service" : service,
          "score" : parseInt(score),
          "sprice" : parseInt(sprice),
        })
      });
      info.push({
        "name" : spl,
        "passenger" : parseInt(passenger),
        "baggager" : parseInt(baggager),
        "price" : parseInt(price.trim()),
        "num" : parseInt(num),
        "datas": res,
      });
    })

    driverResult = {} ;
    driverResult["data"] = info;
    driverResult["city"] = parseInt(city);
    driverResult["date"] = date;
    driverResult["type"] = parseInt(type);
    driverResult["time"] = time;
    driverResult['airport_cn'] = $('input.location').attr('value');
    driverResult['address_cn'] = $('input.address').attr('value');
    driverResult['type_cn'] = $('a.current.change-pt').text();;
    driverResult['airport_code'] = airportCode;
    //console.log(JSON.stringify( driverResult,undefined,3));
    return driverResult;
  }, city, date, time, airportCode, type);
  // casper.capture('comp.png');
  console.log(JSON.stringify({"status": 200, "result": result},undefined,3));

  //console.log(JSON.stringify({"status": 200, "result": result, "created_at": new Date()}));

}, 1000 * 7);

casper.run();





