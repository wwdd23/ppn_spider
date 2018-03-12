module TaskService
  class TaskProcessor

    def self.process_result(results_id)
      results = $dc.get results_id
      Task.transaction do
        results.each do |res|
          begin
            data = res['data']
            error = res['error']
            task = Task.find(res['task_id'])
            Rails.logger.info "== info #{task.id} #{task.status} #{task.attempts}"
            next if task.success? || task.failed? || task.undo?

            if error.present?
              Rails.logger.info "task return error: #{ error }"
              task.return_error
              task.save
              next
            end

            storage_data(task, data) if data.present?
            task.return_data
            task.save

          rescue Exception => e
            Rails.logger.info "process_result error, params: #{res}, error: #{e}"
          end
        end
      end
    end

    def self.process_result2(results)
      failed_ids = []
      success_ids = []

      results.each do |res|
        begin
          data = res['data']
          error = res['error']
          task = Task.find(res['task_id'])
          next if task.success? || task.failed? || task.undo?

          if error.present?
            failed_ids << task.id
            next
          end

          storage_data(task, data) if data.present?
          success_ids << task.id

        rescue Exception => e
          Rails.logger.info "process_result error, params: #{res}, error: #{e}"
        end
      end

      Task.transaction do
        Task.where(:id => failed_ids).each do |n|
          begin
            n.return_error!
          rescue
          end
        end

        Task.where(:id => success_ids).each do |n|
          begin
            n.return_data!
          rescue
          end
        end
      end

      process_callback(results.map{|n| n['task_id']})
    end

    def self.process_callback(ids)
      Task.where(:id => ids).group(:project).count.each do |n, _|
        next unless Task.where(:project => n).where(:status => ['undo', 'deliver']).count == 0

        verify_ids = Task.where(:id => ids).where(:project => n).pluck(:id).map do |m|
          Verify.where("start <= ? and end >= ?", m, m).first.try(:id)
        end.uniq.compact

        Verify.where(:id => verify_ids).each do |r|
          eval(r['command'])
        end
      end
    end

    def add_tasks_to_queue
      script_categories = Task.undo.group(:script_name).count
      script_num = script_categories.count

      Task::CATEGORIES.each do |task_category|
        task_queue = "task_deliver_queue_#{task_category}"
        queue_tasks = $dc.get(task_queue).to_a
        need = 1000 - queue_tasks.count
        p need
        next if need < 1
        tasks = Task.undo.where(category: task_category).sample(need)
        store_tasks = []
        Task.transaction do
          store_tasks = tasks.select do |task|
            begin
              ret = false
              task.deliver
              task.save
              ret = true
            rescue Exception => e
              ret = false
              p "#{e}"
            end
          end
        end

        save_tasks = queue_tasks + store_tasks.map(&:id).shuffle
        $dc.set task_queue, save_tasks
      end

    end

    private

    def self.storage_data(task, data)
      project = task.project
      script_name = task.script_name

      current_date = Date.today.to_s
      url = task.url
      context = Digest::MD5.hexdigest(task.context)

      insert_data = {
        created_at: Time.now,
        project: project,
        data: data,
        date: current_date,
        script_name: script_name,
        url: task.url,
        task_id: task.id,
      }

      $mongo_qspider[script_name.split('/').last].insert(insert_data.except(:script_name, :date).merge(:context => (JSON.parse(task.context) rescue task.context)))
      true
    end

  end
end
