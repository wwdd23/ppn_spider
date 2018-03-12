# encoding: utf-8
require 'grape-swagger'
require 'csv'

module Qspider
  module V1
    class AnalyticsApi < Grape::API
      use ActionDispatch::RemoteIp

      version 'v1', using: :path
      content_type :json, "application/json;charset=UTF-8"
      format :json

      resource :get_mafengwo_show do
        desc "查询马蜂窝展现数据"

        params do
          optional :day, type: String, desc: '日期'
        end

        get do
          AnalyticsService::Analytics.get_mafengwo_show(params[:day])
        end
      end

      resource :get_hot_mafengwo do
        desc "查询马蜂窝热销数据"

        params do
          optional :day, type: String, desc: '日期'
        end

        get do
          AnalyticsService::Analytics.get_hot_mafengwo(params[:day])
        end
      end

      add_swagger_documentation hide_format: true,
                                api_version: 'v1',
                                base_path: "/api",
                                hide_documentation_path: true
    end
  end
end
