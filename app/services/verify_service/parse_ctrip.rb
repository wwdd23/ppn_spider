#encoding: utf-8

module VerifyService
  class ParseCtrip < Base
    def self.doit(start_id, end_id, email)
      r = [['城市', '住宿名称', '房型名称', '入住日期', '链接', '是否展现']]

      Task.where(:id => start_id..end_id).each do |n|
        mg_result = $mongo_yuspider[PROJECT_NAME].find(:task_id => n.id).first
        next unless mg_result && mg_result['data']

        context = JSON.parse(n.context)

        mg_result['data']['rooms'].each do |n|
          r << [
            mg_result['data']['city_name'],
            mg_result['data']['house_name'],
            n['name'],
            mg_result['data']['start_day'],
            n.url,
            m['isExist'] == true && m['isAgent'] == true,
          ]
        end
      end

      Emailer.send_custom_file([email], "携程展示校验", XlsGen.gen(r), "携程展示校验.xls").deliver
    end
  end
end
