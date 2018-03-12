#!/usr/bin/env nodejs

var $ = require('cheerio');
var request = require('request');
var fs = require('fs');


var header = {
 "Host": "sec-m.ctrip.com",
 "Content-Type": "application/json",
 "Connection": "keep-alive",
 "Accept": "application/json",
 //"User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/11B508_eb64__Ctrip_CtripWireless_7.3.0",
 "Accept-Language":"zh-cn",
 //"Accept-Encoding":"gzip, deflate",
 //"x-originating-url": "http://sec-m.ctrip.com/restapi/soa2/10867/query/productsv3",

}
var url = "https://sec-m.ctrip.com/restapi/soa2/10867/query/productsv3"

var params = {
  "biztype": 33,
  "pttype": 18,
  "ctid": 78,
  "ctnm": "Japan",
  "cid": 228,
  "cnm": "东京",
  "auxcid": 0,
  "auxcnm": "",
  "stnno": "",
  "udt": "2017-5-24 16:00",
  "stncd": "NRT",
  "stnnm": "成田国际机场",
  "stntype": 1,
  "stnsubcd": "",
  "stnsubnm": "成田国际机场",
  "locsubtype": 0,
  "poinm": "银座灿路都大饭店",
  "poiadr": "Japan, 〒104-0061 Tōkyō-to, Chūō-ku, Ginza, 1 Chome−15−4, 銀座一丁目ビル 11",

  "poicid": 228,
  "poicnm": "东京",
  "poilat": 35.6735112,
  "poilng": 139.7697642,
  "stnadt": "",
  "stnddt": "",
  "adult": 2,
  "children": 0,
  "bag": 2,
  "sctype": 0,
  "vdrids": [],
  "grpids": [],
  "sveids": [],
  "wlver": "7030.412181",
  "sf": "app",
  "chtype": 7,
  "head": {
    "cid": "12001089310040485132",
    "ctok": "",
    "cver": "703.000",
    "lang": "01",
    "sid": "8890",
    "syscode": "12",
    "auth": null,
    "extension": [{
      "name": "protocal",
      "value": "file"
    }]
  },
  "contentType": "json"
}



request.post({url:url, headers: header, body: JSON.stringify(params)},function(error, response, body) {
  if (error && error.code ==="ETIMEDOUT") {
    process.exit(0);
    return;
  }
  if(response == null) {
    process.exit(0);
    return;
  }
  if(response.statusCode != 200) {
    process.exit(0);
    return;
  }

  console.log(JSON.stringify({"status": 200, "result": JSON.parse(body)},undefined,3));

})






