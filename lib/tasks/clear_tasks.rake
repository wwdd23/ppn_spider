#encoding: utf-8

namespace :tasks do
  task :clear => :environment do
    Task.where("created_at < ?", 1.week.ago).delete_all

    Task.undo.where("created_at < ?", Time.now)
             .where(:script_name => [
               'kancho/kancho_casperjs_ctrip.js',
               'kancho/kancho_casperjs_ctrip_international2.js',
               'kancho/kancho_casperjs_qunar.js'
             ]).delete_all

    Proxy.where("updated_at < ?", 2.week.ago).invalid.delete_all

    [
      'kancho_casperjs_ctrip.js',
      'kancho_casperjs_ctrip_international2.js',
      'kancho_casperjs_qunar.js',
      'proxy_casper.js',
    ].each do |col_name|
      $mongo_yuspider[col_name].remove(:created_at => {:$lt => 1.week.ago.to_time})
    end
  end
end
