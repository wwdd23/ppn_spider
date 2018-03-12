namespace :translate_room_name do
  task :sawadee => :environment do
    connection = $mongo_yuspider.collection('sawadee_roomname_map')
    api_key = "AIzaSyDFOzLVHAikEBWYxyxib43xD3eoQ5ass_c"

    room_names = []
    $mongo_sawadee.find({script_name: /sawadee_room.py/, 'url' => /lg=cn/}, {:timeout => false}) do |cursor|
      cursor.each do |rinfo|
        rinfo['data'].each do |info|
          room_names << info['name']
        end
      end
    end

    p "sum #{room_names.uniq.count}"

    room_names.uniq.compact.each do |rname|
      begin
        room_name = rname
        url = URI.escape "https://www.googleapis.com/language/translate/v2?key=#{api_key}&source=ja&target=zh-CN&q=#{room_name}"
        res = `curl --socks5 127.0.0.1:1080 "#{url}"`
        # res = `/usr/local/bin/proxychains4 curl "#{url}"`
        res_info = JSON.parse(res)
        chinese_name = res_info["data"]["translations"].first['translatedText']
        p "#{room_name} ___  #{chinese_name}"
        connection.update({ room_name: room_name}, { '$set' => { 'chinese_name' => chinese_name } }, { upsert: true })
      rescue Exception => e
        p "translate error #{e}"
      end
    end
  end
end
