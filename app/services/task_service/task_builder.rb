module TaskService
  class TaskBuilder
    def self.create_by_list(new_tasks_id)
      new_task_list = $dc.get new_tasks_id
      Task.transaction do
        new_task_list.each do |new_task|
          begin
            task = Task.new(new_task.to_hash)
            task.save
          rescue Exception => e
            Rails.logger.info "create task failed, params: #{new_task}, error_msg: #{e}"
          end
        end
      end
    end

    def self.create_by_list2(new_task_list)
      Task.transaction do
        new_task_list.each do |new_task|
          begin
            Task.create(new_task.to_hash)
          rescue Exception => e
            Rails.logger.info "create task failed, params: #{new_task}, error_msg: #{e}"
          end
        end
      end
    end
  end
end
