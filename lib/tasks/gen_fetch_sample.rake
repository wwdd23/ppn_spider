# encoding: utf-8

namespace :fetch_sample do
  desc "生成爬取采样时间区间"
  task :update => :environment do
    special_date = [
      ["2016-04-01", "2016-04-04"],
      ["2016-04-29", "2016-05-02"],
      ["2016-06-08", "2016-06-11"],
      ["2016-09-14", "2016-09-17"],
      ["2016-09-29", "2016-09-30"],
      ["2016-10-01", "2016-10-08"],
    ]

    special_date = special_date.map do |n|
      [
        Time.parse(n.first).yesterday.to_date.to_s,
        Time.parse(n.last).yesterday.to_date.to_s,
      ]
    end

    SampleServices::Sample.gen(special_date, SampleServices::Sample.default_path)
  end
end
