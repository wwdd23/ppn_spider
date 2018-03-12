# encoding: utf-8

module Qspider
  module V1
    class ProxyApi < Grape::API
      use ActionDispatch::RemoteIp

      version 'v1', using: :path
      content_type :json, "application/json;charset=UTF-8"
      format :json

      resource :proxy do
        desc "proxy 可用查询"

        params do
          #optional :day, type: String, desc: '日期'
        end

        get do
          Proxy.use_valid.order("RAND()").limit(30).select("ip, port")
        end
      end
    end
  end
end
