# encoding: utf-8

namespace :mongo do

  desc "kancho index"
  task :kancho_index => :environment do
    $mongo_yuspider.collection('kancho').drop_indexes

    $mongo_yuspider.collection('kancho').create_index({
      'date' => Mongo::DESCENDING,
      'script_name' => Mongo::DESCENDING,
      'url' => Mongo::DESCENDING,
      'context' => Mongo::DESCENDING
    }, {:background => true})
  end

  desc "rakuten index"
  task :rakuten_index => :environment do
    $mongo_yuspider['rakuten'].drop_indexes

    $mongo_yuspider['rakuten'].ensure_index({
      'created_at' => Mongo::DESCENDING,
      'script_name' => Mongo::DESCENDING,
    }, {:background => true})

    $mongo_yuspider['rakuten'].ensure_index({
      'date' => Mongo::DESCENDING,
      'script_name' => Mongo::DESCENDING,
      'url' => Mongo::DESCENDING,
      'context' => Mongo::DESCENDING
    }, {:background => true})

    $mongo_yuspider['rakuten'].ensure_index({
      'script_name' => Mongo::DESCENDING,
      'data.hotelid' => Mongo::DESCENDING,
    }, {:background => true})

    $mongo_yuspider['rakuten'].ensure_index({
      'script_name' => Mongo::DESCENDING,
      'data.hotelNo' => Mongo::DESCENDING,
    }, {:background => true})

    $mongo_yuspider['rakuten'].ensure_index({
      'date' => Mongo::DESCENDING,
      'script_name' => Mongo::DESCENDING,
      'data.hotelNo' => Mongo::DESCENDING,
      'data.roomCode' => Mongo::DESCENDING,
      'data.planId' => Mongo::DESCENDING,
      'data.otona_su' => Mongo::DESCENDING,
    }, {:background => true})
  end

  desc "sawadee index"
  task :sawadee_index => :environment do
    # 删除所有 index
    $mongo_yuspider['sawadee'].drop_indexes

    $mongo_yuspider['sawadee'].ensure_index({
      'created_at' => Mongo::DESCENDING,
    }, {:background => true})

    $mongo_yuspider['sawadee'].ensure_index({
      'date' => Mongo::DESCENDING,
      'script_name' => Mongo::DESCENDING,
      'url' => Mongo::DESCENDING,
      'context' => Mongo::DESCENDING
    }, {:background => true})

    $mongo_yuspider['sawadee'].ensure_index({
      'script_name' => Mongo::DESCENDING,
      'data.sawadee_id' => Mongo::DESCENDING,
    }, {:background => true})
  end
end
