class CreateYdjAirports < ActiveRecord::Migration
  def change
    create_table :ydj_airports do |t|
      t.integer :childseatSwitch
      t.string :cityName
      t.integer :timezone
      t.string :neighbourTip
      t.string :continentName
      t.integer :areaCode
      t.string :tip
      t.integer :passcityHotWeight
      t.integer :dstSwitch
      t.string :placeName
      t.integer :cityCode
      t.string :placeCode
      t.integer :cityId
      t.integer :cityInitial
      t.integer :isHotCity
      t.string :cityLocation
      t.string :cityEnName
      t.integer :cityHotWeight
      t.string :citySpell
      t.integer :dstEndTime
      t.integer :dstStartTime
      t.integer :placeId
      t.integer :hasPrice
      t.integer :continentId
      t.integer :isPasscityHot
      t.integer :landingVisaSwitch
      t.integer :bannerSwitch
      t.integer :airportId
      t.string :airportCode
      t.integer :airportHotWeight
      t.integer :isHotAirport
      t.string :airportLocation
      t.string :airportName

      t.timestamps
    end
  end
end


