# encoding: utf-8
namespace :update_coordinate do
  task :sawadee => :environment do
    connection = $mongo_yuspider.collection('sawadee_coordinate')
    api_key = "AIzaSyA9Rit8ICVQIc-ZnORET1_K0CX7dWo45Fo"
    $mongo_sawadee.find({script_name: /sawadee_hotel.py/, 'url' => /lg=en/}, {:timeout => false}) do |cursor|
      cursor.each do |hotel|
        begin
          
          hotel_info = hotel['data']
          hotel_id = hotel_info['sawadee_id']

          next if connection.find({ 'hotel_id' => hotel_id }).first.present?

          location = "#{hotel_info['hoteladr']} #{hotel_info['hotelcity']}"
          url = URI.escape "https://maps.googleapis.com/maps/api/geocode/json?key=#{api_key}&address=#{location}"
          res = `curl --socks5 127.0.0.1:1080 "#{url}"`
          # res = `/usr/local/bin/proxychains4 curl "#{url}"`
          res_info = JSON.parse(res)
          if res_info['status'] == 'OK'
            lat = nil
            lng = nil
            res_info['results'].each do |result|
              if result['geometry']
                lat = result['geometry']['location']['lat']
                lng = result['geometry']['location']['lng']
              end
            end
            raise "获取失败" if lat.nil? || lng.nil?
            coordinate = "#{lat};#{lng}"
            p "#{hotel_id} ___  #{location}  ___ #{coordinate}"
            connection.update({ 'hotel_id' => hotel_id }, { '$set' => { 'coordinate' => coordinate } }, {upsert: true})
          end

        rescue Exception => e
          p "coordinate error: #{e}"
        end
      end
    end
  end
end
