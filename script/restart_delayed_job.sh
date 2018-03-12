#!/bin/bash

#cd /opt/work/dayu-spider
#RAILS_ENV=production script/delayed_job restart --pool=task_process --pool=image_process --pool=order_process

cd /opt/work/qwb_spider/
script/delayed_job restart --pool=task_process --pool=image_process --pool=order_process
