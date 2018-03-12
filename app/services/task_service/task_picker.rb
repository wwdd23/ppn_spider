module TaskService
  class TaskPicker
    TASK_RETURN_NUM = 100

    def random_normal_task(count = TASK_RETURN_NUM)
      random(count, 'normal')
    end

    def random_webkit_task(count = TASK_RETURN_NUM)
      random(count, 'webkit')
    end

    def random_image_task(count = TASK_RETURN_NUM)
      random(count, 'image')
    end

    def random(count, category)

      categories = [category]
      categories << 'normal' if category == 'webkit'

      total_count = Task.undo.count
      if total_count > 1000000
        Task.transaction do
          tasks = Task.undo.offset(rand(total_count)).limit(TASK_RETURN_NUM).shuffle
          tasks.each{|n| n.deliver!}

          return tasks
        end
      end

      script_name_array = Task.undo.where(:category => categories).group(:script_name).count
      return [] if script_name_array.count == 0

      pre_count = TASK_RETURN_NUM / script_name_array.count

      result_tasks = nil
      Task.transaction do
        script_name_array.each do |script_name, count|
          tasks = Task.undo.where(:script_name => script_name).offset(rand([count - TASK_RETURN_NUM, 0].max)).limit(TASK_RETURN_NUM).sample(pre_count).map do |n|
            begin
              n.deliver!
              next(n)
            rescue
              next(nil)
            end
          end.compact

          result_tasks = tasks and next unless result_tasks
          result_tasks += tasks
        end
      end

      result_tasks.shuffle

=begin
      categories = category == 'image' ? [] : ['normal']
      categories.push category if category.present?
      task_ids = get_task_ids_by_categories(categories)
      ret_tasks = Task.where(id: task_ids)
=end

      # script_categories = Task.undo.where(category: categories).group(:script_name).count
      # script_num = script_categories.count

      # return [] if script_num == 0

      # task_count_per_project = [count/script_num, 1].max
      # ret_tasks = []

      # Task.transaction do
      #   script_categories.first(count).each do |script_category, _|
      #     current_task = Task.undo.where(script_name: script_category, category: categories).limit(task_count_per_project)
      #     need_send_task = current_task.select do |tsk|
      #       ret = false
      #       begin
      #         tsk.deliver!
      #         ret = true
      #       rescue Exception => e
      #         Rails.logger.info "task set deliver id: #{tsk.id}, error: #{e}"
      #       end
      #       ret
      #     end
      #     ret_tasks += need_send_task
      #   end
      # end

      # ret_tasks
    end

    private

    def get_task_ids_by_categories(categories)
      return_ids = []
      categories.each do |category|
        queue_category = "task_deliver_queue_#{category}"
        last_tasks = $dc.get queue_category
        ret_tasks = last_tasks.to_a.shift(TASK_RETURN_NUM)
        $dc.set queue_category, last_tasks
        return_ids += ret_tasks
      end
      return_ids
    end

  end
end
