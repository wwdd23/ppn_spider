# encoding: utf-8

namespace :proxy do
  desc "fetch kuaidaili"
  task :kuaidaili => :environment do
    Task.transaction do
      (1..200).each do |page|
        Task.create!({
          url: "http://www.kuaidaili.com/free/inha/#{page}/",
          project: 'proxy',
          category: 'normal',
          script_name: 'proxy/proxy_casper.js',
          context: '',
        })
      end
    end
  end
end
