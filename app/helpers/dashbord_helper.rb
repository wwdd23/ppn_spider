module DashbordHelper
  def get_mega(n)
    n.to_i / 1024 / 1024
  end

  def get_mongodb_stats(collection)
    "#{collection['new_ns_name']}(#{get_mega(collection['size'])}/#{get_mega(collection['storageSize'])})"
  end
end
