class CreateYdjPois < ActiveRecord::Migration
  def change
    create_table :ydj_pois do |t|
      t.integer:childseatSwitch
      t.timestamps  :dstStartTime
      t.integer  :timezone
      t.string  :neighbourTip
      t.string  :continentName
      t.integer  :areaCode
      t.string  :location
      t.integer  :dstSwitch
      t.string  :placeName
      t.integer  :cityCode
      t.string  :intownTip
      t.string  :placeCode
      t.integer :cityId
      t.integer :isHotCity
      t.integer :groups, array: true , default: []
      t.string  :cityInitial
      t.string  :cityEnName
      t.string  :enName
      t.integer  :cityHotWeight
      t.string  :citySpell
      t.timestamps  :dstEndTime
      t.string  :cityLocation
      t.string  :name
      t.string  :cityName
      t.integer  :placeId
      t.integer  :hasPrice
      t.integer  :continentId
    end
  end



end
