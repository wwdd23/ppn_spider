# 实现perform方法支持Delayed_jobs
class DelayJobWrapper

  def initialize(target, action, *args)
    @target = target
    @action = action
    @args = args
  end

  def perform
    if @args.present?
      @target.send(@action, *@args)
    else
      @target.send(@action)
    end
  end

  #need_delete
  def after(job)
    # 某些情况下 @target.order 为空，所以关闭调试
    #passport_order_debug_logger.info "Delayed_job after job_id: #{job.id} order_id: #{@target.order.id} times: #{job.priority} error: #{job.last_error}"
  end

  #need_delete
  def passport_order_debug_logger
    @sms_logger ||= Logger.new("#{Rails.root}/log/passport_order_debug.log")
  end

end
