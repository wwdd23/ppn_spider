# encoding: utf-8

module PriceServices

  class QunarPriceData

    class << self
      def qunaer_price_room_price_data(day)
        #day = "2015-08-27"

        mg_result = $mongo_yuspider['kancho'].find(:date => day, :script_name => 'kancho/kancho_casperjs_qunar.js', :"data.rooms.agents.name" => /大鱼自助游/)

        result = {}
        FETCH_SAMPLE.each do |k, v|

          # prices_min
          # {
          #   room_id => [house_name, room_name, price]
          # }
          prices_min = {}
          mg_result.each do |n|
            next unless k.include?(n['data']['start_day'])
            next if n['data']['rooms'].length < 1

            n['data']['rooms'].each do |m|
              room_id = ""
              room_name = ""
              house_name = n['data']['house_name']

              prices = m['agents'].map do |agent|
                if agent['name'] =~ /大鱼自助游/
                  room_id = agent['roomId'][-11, 11]
                  next(prices_min[room_id][2]) if prices_min.has_key?(room_id)
                  room_name = agent['room_name']
                  next(nil)
                end
                agent['price'].to_f
              end.compact

              next if prices.length == 0
              if prices_min.has_key?(room_id)
                prices_min[room_id][2] = prices.min
                next
              end
              prices_min.store(room_id, [house_name, room_name, prices.min])

            end
          end

          prices_min.each do |key, value|
            v.each do |period|
              result[key] << [value[0], value[1], period[0], period[1], (value[2] - 3).to_i.abs] if result.has_key?(key)
              result.store(key, [[value[0], value[1], period[0], period[1], (value[2] - 3).to_i.abs]]) unless result.has_key?(key)
            end
          end
        end
        
        result
      end
    end

  end
end
