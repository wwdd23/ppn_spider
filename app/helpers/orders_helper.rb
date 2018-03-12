module OrdersHelper
  def get_dayu_link_by_rakuten_url(rakuten_url)
    col = $mongo_fishtrip_houses_list.find({ 'rakuten_url' => rakuten_url }).first
    if col
      return link_to(col['dayu_name'], "http://www.fishtrip.cn/houses/#{col['dayu_param']}", target: "_blank")
    else
      return ""
    end
  end
end
