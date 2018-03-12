#!/usr/bin/env casperjs

var casper = require('casper').create({
  //  clientScripts: ["jquery.min.js"],
  pageSettings: {
 //   "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0",
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36",
    "loadImages": false, //不加载图片
    "loadPlugins": false, 
    //"proxy": "91.73.131.254:8080",
    //"proxy": "http://proxy.abuyun.com:9020",
    //"customHeaders":{
    //  'Authorization':'Basic '+btoa('H96SCQ27VVFVT5PD:6BC8A4E4CA19D5EB')
    }
    //proxy-type: "meh"
   
  }
});

var url = casper.cli.args[0] || 'http://car.ctrip.com/hwdaijia/list?ptType=18&cid=676&useDt=2017-04-28%2014:40&flNo=&dptDt=&locNm=%E6%9D%9C%E5%8B%92%E6%96%AF%E5%9B%BD%E9%99%85%E6%9C%BA%E5%9C%BA&locCd=IAD&locType=1&locSubCd=&locSubType=1&poiCd=17798446&poiType=2&poiNm=The%20Restaurant%20at%20Patowmack%20Farm&poiAddr=42461%20Lovettsville%20Rd.%20Lovettsville%2C%20VA%2020180&poiLng=-77.55584&poiLat=39.278458&poiref=02E89E7A6EEE76F1DBED43E5492D11C6DF1E9078F4A1080EAF4007C246EF278A26A0CDD44FFCD9BE699E41895AA19EB854C230D5BA4B083B2D7E6BF80727E69F1547789959EA1EDA80EB72F212B04097C7AC652B99C2B440F3CC0485594D1D65EF767FC4FED85E27D846D345F2D6F13871A3E8FC33BF8DA7E600B9AE8ACEE800EC44B704B47890E6548B715D204B6C9267971932AA48658EDA9E2E3D2CA291430D03A7A7683B6833B46C3D1B0CF71CAB66D23932D2A230F662AA62E7D73467C8875A20099E991175752278EAF8712B41C36F1F576027F644B543304C4948E5BC40FA685C444D94EA01BD64932A540B2F82B7ED2A7C6AC0C1148DF7D36218771F&addrsource=se';
//var context = casper.cli.args[1] || '{ "start_day": "2016-01-01", "end_day": "2016-01-02"}';

city = url.match(/cid=([0-9]+)/)[1];
date = url.match(/useDt=([0-9]+-[0-9]+-[0-9]+)/)[1];
time = url.match(/useDt.*%20([0-9]+:[0-9]+)&fl/)[1];
airportCode = url.match(/locCd=(\w+)&/)[1];
type = url.match(/ptType=([0-9+])/)[1];

casper.on('remote.message', function(msg) {
  this.echo(msg);
})

casper.on('page.error', function(msg) {
  this.echo(msg);
})

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





