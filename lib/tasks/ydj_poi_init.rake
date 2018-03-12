# encoding utf-8

namespace :ydj do
  desc "fetch ydj location"
  task :poi_init => :environment do

    $mongo_qspider['ydj_location.js'].find(:created_at => {:$gte => Time.parse("2017-07-18")}).each do |n|
      data = n["data"]
      data.each do |k,v|
        v.each do |d|
          YdjPoi.create!(
            {
              childseatSwitch:  d["childseatSwitch"],
              dstSwitch:  d["dstSwitch"],
              timezone:  d["timezone"],
              neighbourTip:  d["neighbourTip"],
              continentName:  d["continentName"],
              areaCode:  d["areaCode"],
              location:  d["location"],
              placeName:  d["placeName"],
              cityCode:  d["cityCode"],
              intownTip:  d["intownTip"],
              placeCode:  d["placeCode"],
              cityId:  d["cityId"],
              isHotCity:  d["isHotCity"],
              #groups:  d["groups"],
              cityInitial:  d["cityInitial"],
              cityEnName:  d["cityEnName"],
              enName:  d["enName"],
              cityHotWeight:  d["cityHotWeight"],
              citySpell:  d["citySpell"],
              cityLocation:  d["cityLocation"],
              name:  d["name"],
              cityName:  d["cityName"],
              placeId:  d["placeId"],
              hasPrice:  d["hasPrice"],
              continentId:  d["continentId"],
            }
          )
        end
      end
    end
  end

  desc "fetch ydj airport poi info"
  task :airport_info => :environment do

    infos = $mongo_qspider['ydj_airport.js'].find.first["data"];nil
    infos.each do |k,v|
      v.each do |n|

        #airports:
        base = ({
          childseatSwitch: n["childseatSwitch"],
          cityName: n["cityName"],
          timezone: n["timezone"],
          neighbourTip: n["neighbourTip"],
          continentName: n["continentName"],
          areaCode: n["areaCode"],
          tip: n["tip"],
          passcityHotWeight: n["passcityHotWeight"],
          dstSwitch: n['dstStartTime'],
          placeName: n['placeName'],
          cityCode: n['cityCode'],
          placeCode: n['placeCode'],
          cityId: n['cityId'],
          cityInitial: n['cityInitial'],
          isHotCity: n['isHotCity'],
          cityLocation: n['cityLocation'],
          cityEnName: n['cityEnName'],
          cityHotWeight: n['cityHotWeight'],
          citySpell: n['citySpell'],
          dstEndTime: n['dstEndTime'],
          dstStartTime: n['dstStartTime'],
          placeId: n['placeId'],
          hasPrice: n['hasPrice'],
          continentId: n['continentId'],
          isPasscityHot: n['isPasscityHot']
        })

        n["airports"].each do |val|
          out = {}
          out = {
            landingVisaSwitch: val["landingVisaSwitch"],
            bannerSwitch: val["bannerSwitch"],
            airportId: val["airportId"],
            airportCode: val["airportCode"],
            airportHotWeight: val["airportHotWeight"],
            isHotAirport: val["isHotAirport"],
            airportLocation: val["airportLocation"],
            airportName: val["airportName"]

          }

          out.merge!(base)
          YdjAirport.create!(out)

        end
      end
    end;nil
  end



end



