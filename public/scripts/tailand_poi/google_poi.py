#!/usr/bin/env python
#coding=utf-8

import requests
import getopt
import sys
import json
from bs4 import BeautifulSoup
import re
import os
import time
from datetime import *
import copy
import time
import pdb
import codecs
import csv
import collections
import sys 
reload(sys) 
sys.setdefaultencoding('utf8')  



# 爬取sawadee的hotel详情页
# http://www.sawadee.cn/hotel/677495

# hotel { name, url, sawadee_id, hoteladr, hotelcity, location, intro, intro, intro
#         pgreview, star, rating_average, review_count, details, location_map_url, area
# }
# url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken&location=13.7563309,100.5017651&radius=200000&types=lodging&name&key=AIzaSyCOb0jmYyLQ1xDvWkBkysCLasKv8-vt5fg"
# https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJ8yTxWq2uQjQRPx2hN4IMZ-Y&key=AIzaSyCOb0jmYyLQ1xDvWkBkysCLasKv8-vt5fg


"""
https://developers.google.com/places/webservice/search

https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=25.061796,%20121.540868&radius=5000&types=lodging&name=&key=AIzaSyCOb0jmYyLQ1xDvWkBkysCLasKv8-vt5fg
"""


class GooglePoi(object):
    def __init__(self):
        pass

    def start(self, radius, step , area_list):

        RADIUS = radius
        STEP = step
        api_key = "AIzaSyDFOzLVHAikEBWYxyxib43xD3eoQ5ass_c"
        # '13.710805, 100.584139'
        # '13.765422, 100.498660'
        AREA_LIST = area_list


        for area in AREA_LIST:

            point = { 'x': area['lefttop']['x'] - STEP/2 , 'y': area['lefttop']['y'] + STEP/2 }
            tmp_y = point['y']
            
            while(point['x'] > area['rightbottom']['x'] ):
                while(point['y'] < area['rightbottom']['y']):
                    # pdb.set_trace()
                    if(point['x'] < 13.776260 and point['y'] > 103.006217):
                        point['y'] = point['y'] + STEP 
                        continue
                    
                    location = str(point['x']) + "," + str(point['y'])
                    
                    print "loading: " + location
                    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken&location=" + location +"&radius=" + str(RADIUS) + "&types=lodging&name&key=" + api_key
                    r = requests.get(url)
                    json_result = r.json()
                    
                    status = json_result.get('status')
                    if status != 'OK'  and status != 'ZERO_RESULTS' :
                        while status == "OVER_QUERY_LIMIT":
                            print "status:" + status
                            time.sleep(6*60*60)
                            r = requests.get(url)
                            json_result = r.json()
                            status = json_result.get('status')
                        else:
                            print status
                            return

                    next_token = json_result.get('next_page_token', None)
                    
                    if not next_token :
                        hotels = json_result['results']
                        print "hotels:" +str( len(hotels ))
                        with codecs.open("tailand_poi.txt","a","UTF-8") as f:
        
                            for hotel in hotels:
                                hotel['url'] = url
                                # pdb.set_trace()
                                #self.db_hotels.insert_one(hotel)
                                if self.isThailand(hotel['place_id']):
                    
                                    f.write(json.dumps(hotel,ensure_ascii=False)+"\n")                         
                                    print str(json.dumps(hotel,ensure_ascii=False))
                                else:
                                    print "not", json.dumps(hotel,ensure_ascii=False)
        
                            f.flush()
                    else :
                        self.start(RADIUS/2, STEP/2 , [{'lefttop': {'x': point['x'] +STEP/2, 'y': point['y'] - STEP/2}, 'rightbottom': {'x': point['x'] - STEP/2, 'y':point['y']+STEP/2}}])

                    point['y'] = point['y'] + STEP
                point['y'] = tmp_y
                point['x'] = point['x'] - STEP


    
    #https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJ17mitgyD4jARwalQbmGdK8Q&key=AIzaSyDFOzLVHAikEBWYxyxib43xD3eoQ5ass_c&language=en
    
    def isThailand(self, placeid):
        """
                   判断是否在泰国
        """
        key = "AIzaSyDFOzLVHAikEBWYxyxib43xD3eoQ5ass_c"
        url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + placeid + "&key=" + key + "&language=en"
        r = requests.get(url)
        json_result = r.json()
        formatted_address = json_result['result'].get('formatted_address')
        return  formatted_address.split()[-1] == "Thailand"
        
    def getNextPageData(self, next_token, source_url = ""):
        api_key = "AIzaSyDFOzLVHAikEBWYxyxib43xD3eoQ5ass_c"
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=" + api_key + "&pagetoken=" + next_token
        # pdb.set_trace()
        print "load next page"
        r = requests.get(url)
        json_result = json.loads(r.text)
        new_next_token = json_result.get('next_page_token', None)
        hotels = json_result['results']
        for hotel in hotels:
            hotel['url'] = source_url
            print hotel
            #self.db_hotels.insert_one(hotel)
        if new_next_token:
            self.getNextPageData(new_next_token, source_url)


         
        
if __name__ == '__main__':
    RADIUS = 50000
    STEP = 0.62
    AREA_LIST = [
         { 'lefttop': {'x':20.449719 , 'y':97.337272}, 'rightbottom': {'x':5.640101 , 'y':105.620964 } }
       ]
    googlePoi =  GooglePoi()
    googlePoi.start(RADIUS , STEP , AREA_LIST )