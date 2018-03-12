class AddContextToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :context, :text
  end
end
