# encoding: utf-8
require 'grape-swagger'

module Qspider
  module V1
    class BaseApi < Grape::API
      use ActionDispatch::RemoteIp

      version 'v1', using: :path
      content_type :json, "application/json;charset=UTF-8"
      format :json

      content_type :gzip, "gzip/json"
      parser :gzip, ->(d, e) do
        data = ActiveSupport::JSON.decode(ActiveSupport::Gzip.decompress(d))
        data = {:_json => data} unless data.is_a?(Hash)
        data.to_options
      end

      helpers do
        def client_ip
          env["action_dispatch.remote_ip"].to_s
        end

        def client_req_task_record(task_ids)
          $mongo_qspider_monitor.update({ip: client_ip}, {'$set' => {req_at: Time.now}}, {upsert: true})
        end

        def client_ret_task_record
          req_at = $mongo_qspider_monitor.find({ip: client_ip}).first.try(:[], 'req_at') || Time.now
          $mongo_qspider_monitor.update({ip: client_ip}, {'$set' => {ret_at: Time.now, running_time: Time.now - req_at}}, {upsert: true})
        end
      end

      resource :tasks do
        desc "返回任务给客户端"
        params do
          optional :category, type: String, desc: 'task类型'
        end
        get do
          ret_tasks = []
          tpicker = TaskService::TaskPicker.new
          if params[:category] && params[:category] == 'image'
            ret_tasks = tpicker.random_image_task
          elsif params[:category] && params[:category] == 'webkit'
            ret_tasks = tpicker.random_webkit_task
          else
            ret_tasks = tpicker.random_normal_task
          end

          client_req_task_record(ret_tasks.map(&:id))

          #task_ids = ret_tasks.map(&:id)
          #client_req_task_record(task_ids.map(&:id))
          #Rails.logger.info "#{client_ip} ==== #{task_ids.join(",")}"
          #ret_tasks.shuffle
          ret_tasks
        end
      end

      resource :fetch do
        desc '返回基础数据'
        params do
          requires :date, type: String, desc: '抓取时间'
          requires :script_name, type: String, desc: '脚本名称'
        end
        get do
          $mongo_qspider[params[:script_name]].find(:created_at => {:$gte => Time.parse(params[:date]), :$lt => Time.parse(params[:date]).tomorrow}).to_a
        end
      end

      resource :results do
=begin
        before do
          #  When the server receives a request with content-type "gzip/json" this will be called which will unzip it,
          #   and then parse it as json
          #  The use case is so clients such as Android or Iphone can zip their long request such as Inviters#addressbook emails
          #  Then the server can unpack the request and parse the parameters as normal.

          if request.content_type == "gzip/json"
            data = ActiveSupport::JSON.decode(ActiveSupport::Gzip.decompress(request.raw_post))
            data = {:_json => data} unless data.is_a?(Hash)
            params ||= {}
            self.params.merge!(data.to_options) #params.merge(data.with_indifferent_access).inject({}){|temp,(k,v)| temp[k.to_sym] = v; temp} # replace string keys with symbols
          end
        end
=end
        desc "接收客户端返回数据"
        params do
          optional :new_tasks, type: Array do
            requires :url, type: String, desc: '任务链接'
            requires :project, type: String, desc: '任务所属项目'
            requires :category, type: String, desc: '任务类型'
            requires :script_name, type: String, desc: '链接抓取脚本'
          end
          optional :results, type: Array do
            requires :task_id, type: Integer, desc: '任务id'
            optional :data, desc: '任务执行结果数据'
            optional :error, desc: '任务执行错误'
          end
        end
        post '/' do
          TaskService::TaskBuilder.create_by_list2(params[:new_tasks])
          TaskService::TaskProcessor.process_result2(params[:results])

          client_ret_task_record
=begin
          time_stamp = Time.now.to_i
          new_tasks_id = "new_tasks_#{time_stamp}"
          results_id = "results_#{time_stamp}"

          $dc.set new_tasks_id, params[:new_tasks], 24.hours.to_i
          $dc.set results_id, params[:results], 24.hours.to_i

          client_ret_task_record

          Delayed::Job.enqueue(DelayJobWrapper.new(TaskService::TaskBuilder, :create_by_list, new_tasks_id), {queue: Settings.queue.tasks})
          Delayed::Job.enqueue(DelayJobWrapper.new(TaskService::TaskProcessor, :process_result, results_id), {queue: Settings.queue.tasks})
=end
        end

        desc "根据项目名称返回抓取数据"
        params do
          requires :project_name, type: String, desc: '项目名称'
          optional :task_id, type: Integer, desc: '任务id'
          optional :date, type: String, desc: '抓取日期'
          optional :script_name, type: String, desc: '抓取脚本名称'
        end
        get '/' do
          project_name = params[:project_name]
          query = {}
          query['date'] = params[:date] if params[:date].present?
          query['script_name'] = params[:script_name] if params[:script_name].present?
          query['task_id'] = params[:task_id] if params[:task_id].present?
          $mongo_qspider.collection(project_name).find(query, fields: ['data', 'script_name'])
        end
      end

      mount Qspider::V1::KanchoApi

      add_swagger_documentation hide_format: true,
                                api_version: 'v1',
                                base_path: "/api",
                                hide_documentation_path: true
    end
  end
end
