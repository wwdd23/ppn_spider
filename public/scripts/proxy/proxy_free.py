#!/usr/bin/env python
#coding=utf-8

import os, sys, re, json
import subprocess
import requests
from lxml import etree

headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36'}
timeout = 20

usableIp = []

for i in range(1, 11):
    """
    try:
        url = "http://proxy-list.org/english/search.php?search=CN.ssl-no&country=CN&type=any&port=any&ssl=no&p=%d" % i

        r = requests.get(url, headers = headers, timeout = timeout)
        r.encoding = "utf-8"

        for li in etree.HTML(r.content).xpath("//li[@class='proxy']"):
            try:
                address, port = re.findall("([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}):([0-9]+)", li.text)[0]
                usableIp.append({"ip":address, "port":port, "type":"http"})
            except:
                pass
    except:
        pass
    """

    ########################################

    """
    try:
        url = "http://www.kuaidaili.com/free/intr/%d/" % i

        r = requests.get(url, headers = headers, timeout = timeout)
        r.encoding = "utf-8"

        for address,port in re.findall("([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})<\/td>\n +<td>([0-9]+)<\/td>", r.content):
            usableIp.append({"ip":address, "port":port, "type":"http"})
    except:
        pass
    """

    ###############################################

    try:
        url = "http://www.xicidaili.com/nn/%d" % i
        r = requests.get(url, headers = headers, timeout = timeout)
        r.encoding = "utf-8"
        for address4,port4 in re.findall("([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})<\/td>\s*<td>([0-9]+)<\/td>", r.content):
          usableIp.append({"ip":address4, "port":port4, "type":"http"})
    except:
      pass

    ########################################

    try:

      url = "http://www.xsdaili.com/index.php?s=/index/mfdl/type/1/p/%d.html" % i
      r = requests.get(url, headers = headers, timeout = timeout)
      r.encoding = "utf-8"
      for address,port in re.findall("([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})<\/td>\s*<td>([0-9]+)<\/td>", r.content):
        usableIp.append({"ip":address, "port":port, "type":"http"})

    except:
      pass

    ########################################

    try:

      indexlist = ["areaindex_1", "areaindex_19", "areaindex_13","areaindex_12","areaindex_11","areaindex_10"]
      for index in indexlist:
        url = "http://www.66ip.cn/%s/%d.html" % (index,i)
        r = requests.get(url, headers = headers, timeout = timeout)
        r.encoding = "utf-8"
        for address4,port4 in re.findall("([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})<\/td>\s*<td>([0-9]+)<\/td>", r.content):
          usableIp.append({"ip":address4, "port":port4, "type":"http"})

    except:
      pass

print json.dumps(usableIp)
sys.exit(0)

####################################################################

uniqIp = []
for i in usableIp:
    try:
        for k in uniqIp:
            if k['ip'] == i['ip'] and k['type'] == i['type'] and k['type'] == i['type']:
                raise 'ip address repeat'

        uniqIp.append({"ip": i['ip'], "port": i['port'], "type": i['type']})
    except:
        pass

#print json.dumps(uniqIp)

valid_ip = []
for i in uniqIp:
    result_code = subprocess.call(['python', os.path.normpath('%s/../proxy_checkIp.py' % __file__), i['ip'], i['port']], env = os.environ.copy(), stdout = open(os.devnull, 'wb'), stderr = open(os.devnull, 'wb'))
    if result_code == 0:
        valid_ip.append({"ip": i['ip'], "port": i['port'], "type":"http"})

print json.dumps(valid_ip)
