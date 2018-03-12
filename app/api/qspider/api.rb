module Qspider
  class API < Grape::API
    mount Qspider::V1::BaseApi
    mount Qspider::V1::AnalyticsApi
    mount Qspider::V1::ProxyApi
  end
end
