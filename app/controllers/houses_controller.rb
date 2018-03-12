# encoding: utf-8

class HousesController < ApplicationController
  before_filter :init_data
  http_basic_authenticate_with name: "dayu_spider", password: "dayu_spider", except: [:mafengwo_redirect]

  def sight_photos
    house_id = params[:house_id]
    zizaike_house_id = params[:zizaike_house_id]
    zizaike_house = @mongo_zizaike_houses_list.find({'house_id' => zizaike_house_id }).first
    path = "#{zizaike_house['province']}/#{zizaike_house['mafengwo_number']}"

    url = URI.parse("#{Settings.fishtrip_fast_online_api}/houses/#{house_id}/rooms?api_key=#{Settings.fishtrip_fast_online_api_key}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    rooms_info = res.body

    @rooms = JSON.parse rooms_info
    @files = Dir.glob("public/images/mafengwo/#{path}/images/**/*").select{|f| !File.directory?(f)}
    @files = @files.map{|file| file.gsub('public', '')}
  end

  def house_photos
    house_id = params[:house_id]
    path = params[:path]
    room_ids = params[:room_ids].split(",")
    room_names = params[:room_names].split(",")
    @rooms = room_names.zip(room_ids)
    @rooms.push(['住宿', "houseid:#{house_id}"])

    @files = Dir.glob("public/spider_images/korea/#{path}/mafengwo/*").select{|f| !File.directory?(f)}
    @files = @files.map{|file| file.gsub('public', '')}
  end

  def mafengwo_redirect
    zizaike_id = params[:zizaike_id]
    zizaike_house = @mongo_zizaike_houses_list.find({'house_id' => zizaike_id}).first

    mafengwo_url = nil
    if zizaike_house.present?
      mafengwo_id = zizaike_house['mafengwo_number']
      mafengwo_url = "http://www.mafengwo.cn/hotel/#{mafengwo_id}.html" if mafengwo_id.present?
    end

    redirect_to mafengwo_url and return if mafengwo_url.present?
    render text: '没有找到对应的马蜂窝链接!'
  end

  def update_sight_photos
    param_str = params[:room_photos]

    begin
      room_photos_array = JSON.parse(param_str)
      room_photos_array.each do |rphoto|
        file = rphoto['file_path']
        room_id = rphoto['room_id']
        if room_id.start_with?("houseid:")
          house_id = room_id.gsub("houseid:", '')
          Delayed::Job.enqueue(DelayJobWrapper.new(FastOnline::UploadHousesPhotosWorker.new, :perform, file, house_id), {queue: Settings.queue.image})
        else
          Delayed::Job.enqueue(DelayJobWrapper.new(FastOnline::UploadSightPhotosWorker.new, :perform, file, room_id), {queue: Settings.queue.image})
        end
      end
      status = 'success'
    rescue Exception => e
      status = 'failed'
      msg = e
    end

    respond_to do |format|
      format.json {
        render json: {
          status: status,
          msg: msg
        }
      }
    end
  end

  def init_data
    @mongo_zizaike_houses_list = $mongo_mafengwo_spider.collection('zizaike_houses_list')
  end
end
