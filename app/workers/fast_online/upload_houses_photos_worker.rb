# encoding: utf-8
module FastOnline

  class UploadHousesPhotosWorker

    def perform(file_path, house_id)
      house_api = "#{Settings.fishtrip_fast_online_api}/houses"
      begin
        data = RestClient.put "#{house_api}/#{house_id}/update_sight_photo", :sight_photo => File.new(file_path), api_key: Settings.fishtrip_fast_online_api_key
        sight_photo_info = JSON.parse(data)
        p "#{sight_photo_info['msg']}"
      rescue Exception => e
        p "#{e}"
      end
    end

  end

end
