# encoding: utf-8
module Qspider
  module V1
    class KanchoApi < Grape::API

      helpers do
        def mongo_kancho
          $mongo_qspider.collection('kancho')
        end

        def pick_data(res)
          ret = res.map do |col|
            col['data']
          end
          ret
        end
      end

      #namespace :kancho do
      #  mount Yuspider::V1::MfwApi
      #  mount Yuspider::V1::CtripApi
      #  mount Yuspider::V1::QunarApi
      #end
    end
  end
end
