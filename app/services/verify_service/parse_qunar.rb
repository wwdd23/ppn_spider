#encoding: utf-8

module VerifyService
  class ParseQunar < Base
    def self.doit(start_id, end_id, email)
      #mg_result = $mongo_yuspider[PROJECT_NAME].find(:task_id.in => start_id..end_id, :"data.rooms.agents.name" => /大鱼自助游/)

      r = [['城市', 'id', '住宿名称', '房型名称', '入住日期', '链接', '是否展现']]

      Task.where(:id => start_id..end_id).each do |n|
        mg_result = $mongo_yuspider[PROJECT_NAME].find(:task_id => n.id, :"data.rooms.agents.name" => /大鱼自助游/).first

        city_and_date = n.url.match(/city\/([\s\S]+)\/([\s\S]+)\/.*fromDate=([^&]+)/)

        if mg_result
          mg_result['data']['rooms'].each do |m|
            agent = m['agents'].select{|k| k['name'] =~ /大鱼自助游/}.first

            r << [
              city_and_date[1],
              city_and_date[2],
              mg_result['data']['house_name'],
              m['name'],
              city_and_date[3],
              n.url,
              agent.present?,
            ]
          end
        else
          r << [
            city_and_date[1],
            city_and_date[2],
            nil,
            nil,
            city_and_date[3],
            n.url,
            false,
          ]
        end
      end

      Emailer.send_custom_file([email], "去哪儿展示校验", XlsGen.gen(r), "去哪儿展示校验.xls").deliver
    end
  end
end
