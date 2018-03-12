# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#every 1.minutes do
#  #rake "frequent_add_task_to_category_queue:import_queue"
#end

every 12.hours do
  runner "ProxyService::Proxy.fetch"
  runner "ProxyService::Proxy.verify"
  rake "proxy:kuaidaili"
end

every 1.hours do
  rake 'tasks:reset_delivered_when_timeout'
end

# 暂停
#every 1.hours do
#  rake 'create_ctrip:alading'
#end
#
#
# 暂停
#every :day , :at => '7:00am' do
#
#  rake 'create_ctrip:report_alading'
#end

every :day, :at => '0:00am' do
  rake 'tasks:clear'
end

every 20.minutes do
  runner "ProxyService::Proxy.verify"
end

every 2.hours do
  runner "ProxyService::Proxy.ipproxy_get"
  #rake "frequent_add_task_to_category_queue:import_queue"
end

#every :day, :at => '8:00am' do
#  #rake 'kancho_tasks_init:init_ctrip_inter_price'
#end
#
#every :day, :at => '1:30am' do
#  rake 'kancho_tasks_init:init_ctrip'
#  rake 'kancho_tasks_init:init_qunar_price'
#  #rake 'kancho_tasks_init:init_ctrip_hot'
#  #rake 'kancho_tasks_init:init_qunar_taiwan_price'
#end
#
#every :day, :at => '1:00pm' do
#  rake 'kancho_tasks_init:init_ctrip_international'
#end
#
#every :day, :at => '11:00am' do
#  #rake 'avengers_tasks:init_crazy_click'
#end
#
##乐天价格日历持续抓取
#every :day, :at => '1:00am' do
#  #rake 'rakuten_task_init:init_rakuten_plan_info rev=false cal=ture hotel=false c_m=7'
#end
