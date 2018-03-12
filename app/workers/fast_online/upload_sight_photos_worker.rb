# encoding: utf-8
module FastOnline

  class UploadSightPhotosWorker

    def perform(file_path, room_id)
      rooms_api = "#{Settings.fishtrip_fast_online_api}/rooms"
      begin
        data = RestClient.put "#{rooms_api}/#{room_id}/update_sight_photo", :sight_photo => File.new(file_path), api_key: Settings.fishtrip_fast_online_api_key
        sight_photo_info = JSON.parse(data)
        p "#{sight_photo_info['msg']}"
      rescue Exception => e
        p "#{e}"
      end
    end

  end

end
