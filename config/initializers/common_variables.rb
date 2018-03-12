CITY_CONFIG = YAML.load_file("#{Rails.root}/config/thailand_city_mapping.yml")['cities']
$sawadee_city_mapping = {}
CITY_CONFIG.each do |city_map|
  $sawadee_city_mapping[city_map['english_name']] = city_map['yu_id']
end
