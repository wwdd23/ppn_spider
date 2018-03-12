#encoding: utf-8

module AnalyticsService
  class Analytics
    KANCHO_PRJ = 'kancho'

    class << self
      def get_mafengwo_show(day = nil)
        day ||= Date.current.to_s

        mafengwo_house = CSV.read('data/mafengwo_house.csv')

        {
          :tw_show_count => $mongo_yuspider[KANCHO_PRJ].find({:date => day, :script_name => 'kancho/kancho_mfw_checkExist.py'}).select{|row| row['data']['country_name'] == '中国' && row['data']['ota'].select{|n| n['ename'] == 'fishtrip'}.count >= 1}.count,
          :jp_show_count => $mongo_yuspider[KANCHO_PRJ].find({:date => day, :script_name => 'kancho/kancho_mfw_checkExist.py'}).select{|row| row['data']['country_name'] == '日本' && row['data']['ota'].select{|n| n['ename'] == 'fishtrip'}.count >= 1}.count,
          :tw_online_count => mafengwo_house.select{|row| row[5] == '台湾'}.count,
          :jp_online_count => mafengwo_house.select{|row| row[5] == '日本'}.count,
        }
      end

      def get_hot_mafengwo(day = nil)
        day ||= Date.current.to_s

        hot_house = []
        dayu_hot_house = []
        $mongo_yuspider[KANCHO_PRJ].find({:date => day, :script_name => /mfw_hotHouse/}).each do |row|
          dayu_hot_house.concat(row['data']['hot_house'].select{|n| n['check_dayu']}.map{|n| n['house_name']})
          hot_house.concat(row['data']['hot_house'].map{|n| n['house_name']})
        end

        {
          :hot_house_count => hot_house.uniq.count,
          :dayu_hot_house_count => dayu_hot_house.uniq.count,
        }
      end
    end
  end
end
