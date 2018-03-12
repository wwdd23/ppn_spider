#!/usr/bin/env python
#coding=utf-8

# 获取 http://www.proxy.com.ru 前5页(250个)IP，将有效的返回。

'''
[
    {
        "ip": "10.23.23.4",
        "port": "8089",
        "type": "http"
    }
]
'''

import requests
from bs4 import BeautifulSoup
import re
import socket
import json

pageNum = 2

#totalCount = 0
#goodCount = 0

usableIp = []

for i in range(pageNum):
    p = i + 1

    url = "http://www.proxy.com.ru/list_"+str(p)+".html"

    headers={'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36'}
    r = requests.get(url, headers=headers)
    r.encoding = "utf-8"

    trs = re.findall("<tr><b><td>\d+</td><td>(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})</td><td>(\d{1,5})</td><td>.+</td><td>.+</td></b></tr>", r.text)

    for i, tr in enumerate(trs):

        #totalCount += 1
        #print i, tr
        ip = tr[0]
        port = tr[1]

        usableIp.append({"ip":ip, "port":port, "type":"http"})
        continue
        
        proxies = {"http": "http://"+ip+":"+port}
        try:
            r = requests.get("http://www.baidu.com", proxies=proxies, timeout=2)
        except (requests.exceptions.RequestException, socket.timeout):
            #print "Error"
            continue
        if(r.status_code == requests.codes.ok):
            #goodCount += 1
            usableIp.append({"ip":ip, "port":port, "type":"http"})

#print "total", totalCount
#print "available", goodCount

sendBack = json.dumps(usableIp)
print sendBack
