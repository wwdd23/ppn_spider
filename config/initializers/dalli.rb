require 'dalli'
MEM_CONFIG = YAML.load_file("#{Rails.root}/config/memcached.yml")[Rails.env] 
$dc = Dalli::Client.new("#{MEM_CONFIG['host']}:11211", { :namespace => MEM_CONFIG['namespace'], :compress => true })