#encoding: utf-8

namespace :avengers_tasks do
  desc "初始化马蜂窝已上线住宿"
  task :init_crazy_click => :environment do
    max_count = ENV['count'] || 10000

    Task.transaction do
      (0..max_count).each do |i|
        task_info = {
          url: "dummy_#{i}",
          project:'avengers',
          category: 'webkit',
          script_name: 'avengers/avengers_mafengwo.js',
          context: '',
        }
        Task.create!(task_info)
      end
    end
  end
end
