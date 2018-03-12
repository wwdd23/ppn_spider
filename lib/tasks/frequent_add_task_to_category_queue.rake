# encoding: utf-8
namespace :frequent_add_task_to_category_queue do
  desc "定时导入deliver队列"
  task :import_queue => :environment do
    TaskService::TaskProcessor.new.add_tasks_to_queue
  end
end
