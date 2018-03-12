# encoding: utf-8

module PriceServices
  class CtripPriceData
    def self.ctrip_inter_price_data(day, id)
      #date = params[:date] || Time.now.yesterday.to_date.to_s
      query = {
        :date => day,
        :'data.house_id' => id,
        # :'data.house_id' => "3113053",
        :script_name => 'kancho/kancho_casperjs_ctrip_international.js',
      }
      base_data = $mongo_yuspider['kancho'].find(query).to_a
      return {} unless base_data.present?
      result = {}
      info = base_data.first['data']
      result['house_id'] = info['house_id']
      result['house_name'] = info['house_name']
      result['area'] = info['area']
      result['country'] = info['country_name']
      result['city'] = info['city_name']
      result['date'] = []

      FETCH_SAMPLE.each do |k, v|
        res = {}
        base_data.each do |n|
          next unless k.include?(n['data']['start_day'])
          next if n['data']['rooms'].length < 1

          res['day'] = n['data']['start_day']
          res['room_data'] = []
          case  n['data']['page_mod']
          when "one_pic"
            info_select = base_data.select{|select| select['data']['start_day'] == n['data']['start_day'] }
            info_select.first['data']['rooms'].each do |m|
              base_pic_key = m['casper_base_class']
              pic_res = info_select.first['data']['pic'].select{|pic| pic['pic_key'] == base_pic_key}
              pic_decode = Base64.decode64(pic_res.first['pic_b64'])
              base_price = pic_decode.present? ? RTesseract.new('').from_blob(pic_decode).to_s.strip.to_i : 0
              res['room_data'] << {
                "room_name" => m['room_name'],
                "room_type" => m['room_type'],
                "room_service" => m['room_service'],
                "room_price" => m['room_price'],
                "base_price" => base_price,
                "base_key" => m['casper_base_class'],
                "isAgent" => m['isAgent'],
                "canBuy" => m['canBuy'],
                "coupon" => m['coupon'],
              }
            end
          when "two_pic"
            info_select = base_data.select{|select| select['data']['start_day'] == n['data']['start_day'] }
            info_select.first['data']['rooms'].each do |m|
              base_pic_key = m['casper_base_class']
              pic_res = info_select.first['data']['pic'].select{|n| n['pic_key'] == base_pic_key}
              pic_decode = Base64.decode64(pic_res.first['pic_b64'])
              room_pic_decode = Base64.decode64(pic_res.first['room_pic_b64'])
              base_price = pic_decode.present? ? RTesseract.new('').from_blob(pic_decode).to_s.strip.to_i : 0
              room_price = room_pic_decode.present? ?  RTesseract.new('').from_blob(room_pic_decode).to_s.strip.to_i : 0
              res['room_data'] << {
                "room_name" => m['room_name'],
                "room_type" => m['room_type'],
                "room_service" => m['room_service'],
                "room_price" => room_price,
                "base_price" => base_price,
                "base_key" => m['casper_base_class'],
                "room_key" => m['casper_room_class'],
                "isAgent" => m['isAgent'],
                "canBuy" => m['canBuy'],
                "coupon" => m['coupon'],
              }
            end
          end
        end

        copy_room = res['room_data']
        # next unless k.include?(res['day'])
        if v[0].class == String
          (v[0].to_date..v[1].to_date).each do |d|
            result['date'] << {
              "day" => d.to_s,
              "room_date" => copy_room
            }
          end
        else
          v.each do |v_n|
            (v_n[0].to_date..v_n[1].to_date).each do |d|
              result['date'] << {
                "day" => d.to_s,
                "room_date" => copy_room
              }
            end
          end
        end

      end

      # {
      #  house_id => xxx,
      #  house_name => xxx,
      #  area => xxx,
      #  country => xxx,
      #  city => xxx,
      #  date => [
      #   {
      #     room_name => xxx,
      #     room_type => xxx,
      #     room_service => xxx,
      #     room_price => xxx,
      #     ...
      #   },
      #   ...
      #  ]
      # }
      result
    end

    def self.pick_data_taiwan(date, house_id, is_core)
      pick_data($mongo_yuspider['kancho_casperjs_ctrip.js'], date, house_id, is_core)
    end

    def self.pick_data_international(date, house_id, is_core)
      return pick_data($mongo_yuspider['kancho_casperjs_ctrip_international2.js'], date, house_id, is_core).map do |n|
        n['rooms'].each{|m| m['id'] = m['room_id'].to_i; m};
        n
      end

      return r unless r.count > 0

      r.group_by do |n|
        n['start_day']
      end.map do |start_day, items|
        {
          :start_day => start_day,
          :house_name => items.first['house_name'],
          :city_name => items.first['city_name'],
          :country_name => items.first['country_name'],
          :house_id => items.first['house_id'],
          :rooms => items,
        }
      end
    end

    private
    def self.pick_data(collection, date, house_id, is_core)
      filter = {}
      filter.merge!(:created_at => {:$gte => Time.parse(date), :$lt => Time.parse(date).tomorrow})
      filter.merge!(:'data.house_id' => house_id)

      return collection.find(filter).map{|n| n['data']} if is_core

      r = []
      collection.find(filter).each do |n|
        SampleServices::Sample.get_span(n['data']['start_day']).each do |day|
          data = n['data'].dup
          data['start_day'] = day

          r << data
        end
      end

      r.group_by do |n|
        n['start_day']
      end.map do |day, items|
        items.first
      end
    end
  end
end
