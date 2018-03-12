#!/usr/bin/env casperjs

var casper = require('casper').create({
  //  clientScripts: ["jquery.min.js"],
  pageSettings: {
    "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0",
    "loadImages": false,
  }
});


var url = casper.cli.args[0] || "http://car.ctrip.com/dayweb/city219?date=2018-02-13%2016:00:00&duration=1&refs=%7B%22cityId%22:219,%22items%22:[%7B%22cityIds%22:[],%22day%22:1,%22pathType%22:1,%22desctription%22:%22%E5%A4%A7%E9%98%AA%E5%B8%82%E5%86%85%E5%8C%85%E8%BD%A6%E6%9C%8D%E5%8A%A1%22%7D]%7D&iscross=false&isreturn=false&staydur=0" 

var s = "{\"time\":\"2017-11-03T16:58:36.533+08:00\",\"text\":\"date=2018-02-13 16:00:00\\u0026duration=1\\u0026refs={\\\"cityId\\\":219,\\\"items\\\":[{\\\"cityIds\\\":[],\\\"day\\\":1,\\\"pathType\\\":1,\\\"desctription\\\":\\\"大阪市内包车服务\\\"}]}\\u0026iscross=false\\u0026isreturn=false\\u0026staydur=0\"}"
var context = casper.cli.args[1] || s 


//var s = encodeURI('date=2017-11-11 09:00:00&duration=1&refs={\"cityId\":58,\"items\":[{\"cityIds\":[],\"day\":1,\"pathType\":1}]}&iscross=false&isreturn=false&staydur=0')


//var url = casper.cli.args[0] || 'http://car.ctrip.com/dayweb/city1210?date=2018-02-14 11:00&duration=5&refs={"cityId":1210,"items":[{"cityIds":[1210],"day":1,"desctription":"黄金海岸周边包车服务","pathType":2,"scope":""},{"cityIds":[],"day":2,"desctription":"黄金海岸市内包车服务","pathType":1,"scope":""},{"cityIds":[],"day":3,"desctription":"黄金海岸市内包车服务","pathType":1,"scope":""},{"cityIds":[],"day":4,"desctription":"黄金海岸市内包车服务","pathType":1,"scope":""},{"cityIds":[],"day":5,"desctription":"黄金海岸市内包车服务","pathType":1,"scope":""}]}&iscross=false&isreturn=false&staydur=0'
city = url.match(/city([0-9]+)/)[1];
//var date = url.match(/city([0-9]+)/)[1];
date = url.match(/date=([0-9]+-[0-9]+-[0-9]+)/)[1];
time = url.match(/%20([0-9]+:[0-9]+)/)[1];
type = url.match(/duration=([0-9+])/)[1];
log_time = JSON.parse(s)["time"]


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


casper.start(url).waitFor(function(){
  return this.evaluate(function(){
    //return $(".txt_taxtips").length > 0;
    return $('.cl_type').length > 0
  })
}, function(){
  var result = this.evaluate(function(city, date, type ,time, log_time){
    var info = [];
    // 最低价位置内容
    $('div.cl_type').each(function() {
      var passenger = $(this).find('big .passenger').next().text();
      var baggager = $(this).find('.baggage').next().text();
      var all_big = $(this).text().replace(/\s/g,"");
      var spl = all_big.split(passenger + baggager)[0];
      var price = $(this).find('.type_price big').text();
      var num = $(this).find('.type_price .num').text();
      //console.log($(this).find('.s_logo').text());
      //console.log(num)

      // 没量车价格
      var res = [];
      $(this).next().find('.bb').each(function() {
        var supply = $(this).find('.supply').text().replace(/\s/g,"");
        var service = [];
        $(this).find('.service em').each(function() {
          service.push($(this).text().trim().replace(/\s/g,","));
        });
        var score  = $(this).find('.score big').text();
        var sprice = $(this).find('.prix big').text();
        var pointcount  = $(this).find('.score span').attr('data-pointcount');
        if (pointcount == undefined){

          pointcount = 0
        }
        

        res.push ({
          "supply" : supply,
          "service" : service,
          "score" : parseInt(score),
          "sprice" : parseInt(sprice),
          "pointcount" : parseInt(pointcount),
        })
      });

      info.push({
        "name" : spl,
        "passenger" : parseInt(passenger),
        "baggager" : parseInt(baggager),
        "lowprice" : parseInt(price),
        "num" : parseInt(num),
        "datas" : res,
      })
    })

    driverResult = {} ;
    driverResult["data"] = info;
    driverResult["city"] = parseInt(city);
    driverResult["date"] = date;
    driverResult["type"] = parseInt(type);
    driverResult["time"] = time;
    driverResult["log_time"] = log_time;
    driverResult['city_cn'] = $('input#useCid').attr('value');
    driverResult['type_cn'] = $('input#useDuration').attr('value');

    //console.log(JSON.stringify( driverResult,undefined,3));
    return driverResult;
  },city,date,type,time );
  // casper.capture('comp.png');
  console.log(JSON.stringify({"status": 200, "result": result},undefined,3));
}, 1000 * 50);

casper.run();


