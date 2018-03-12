class ChangeTasksStatusDefaultToNil < ActiveRecord::Migration
  def change
    change_column_default :tasks, :status, nil
  end
end
