#!/bin/bash
###################
# Author:  wudi
# Mail: programmerwudi@gmail.com 
# Description: 
# Created Time: 2017-04-12 18:26:24
###################

echo "look pid"
ps aux |grep unicorn

echo "git pull start..."
git pull; kill -9 `cat /opt/ppn_spider/tmp/pids/unicorn_data.pid` ; bundle exec unicorn_rails -E development -D -c /opt/ppn_spider/config/unicorn.rb; ps aux |grep unicorn

whenever --update-crontab --set environment='development'

echo "Restart end.."
