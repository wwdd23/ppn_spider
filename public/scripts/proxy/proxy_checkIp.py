#!/usr/bin/env python
#coding=utf-8

# 给定某个IP，验证有效性。返回 True/False


import requests
import json
import sys
import socket

TIMEOUT_TIME = 1

proxies = {"http": "http://%s:%s" % (sys.argv[1], sys.argv[2])}
try:
    r = requests.get("http://www.baidu.com", proxies=proxies, timeout=TIMEOUT_TIME)
    r.encoding = "utf-8"
    if r.content.find("百度搜索") == -1:
        raise 'err'

except:
    print False
    sys.exit(1)

print True
