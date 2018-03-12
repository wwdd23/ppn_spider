#!/usr/bin/env casperjs

var casper = require('casper').create({
  pageSettings: {
    "userAgent": require('system').env['dayu_ua'] || "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36",
    "loadImages": false,
  }
});

var url = casper.cli.args[0] || 'http://www.kuaidaili.com/free/inha/3/';
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
  return this.evaluate(function(params){
    return typeof($) != 'undefined' && $("tr").length > 0;
  }, {debug: debug, dummy: true});
}, function(){
  var result = this.evaluate(function(params){
    var r = [];
    $(".table tr").each(function(){
      if ($(this).find("[data-title=\"IP\"]").length == 0){
        return;
      }
      
      r.push({
        ip: $(this).find("[data-title=\"IP\"]").text(),
        port: $(this).find("[data-title=\"PORT\"]").text(),
      });
    })

    return r;
  }, {debug: debug, dummy: true});

  require('utils').dump({
    status: 200,
    result: result
  });
})

casper.run();
