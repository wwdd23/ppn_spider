#encoding: utf-8

namespace :tasks do
  task :reset_delivered_when_timeout => :environment do
    Task.transaction do
      Task.delivered.where("updated_at < ?", 1.hours.ago).update_all(:status => 'undo', :attempts => 0)
    end
  end
end
