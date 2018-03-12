require 'mongo'

MONGO_CONFIG = YAML.load_file("#{Rails.root}/config/mongodb.yml")[Rails.env]
#SPIDER_MONGO_CONFIG = YAML.load_file("#{Rails.root}/config/spider_mongodb.yml")[Rails.env]
mongo_conn = Mongo::Connection.new(MONGO_CONFIG['host'], MONGO_CONFIG['port'])

$mongo_qspider = mongo_conn.db(MONGO_CONFIG['database'])
$mongo_qspider_monitor = $mongo_qspider.collection('monitor')
$mongo_proxy = mongo_conn.db(MONGO_CONFIG['proxy_database'])
$analysis_data = mongo_conn.db(MONGO_CONFIG['analysis_database'])

# $mongo_fishtrip_houses_list = $mongo_qwbspider.collection('fishtrip_houses_list')
# $mongo_mafengwo_spider = mongo_conn.db(SPIDER_MONGO_CONFIG['mafengwo_database'])
# $mongo_rakuten_spider = mongo_conn.db(SPIDER_MONGO_CONFIG['database'])
# 
# $mongo_sawadee = $mongo_qwbspider.collection('sawadee')
