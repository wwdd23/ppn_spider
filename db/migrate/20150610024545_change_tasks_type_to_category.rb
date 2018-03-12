class ChangeTasksTypeToCategory < ActiveRecord::Migration
  def change
    rename_column :tasks, :type, :category
    change_column :tasks, :category, :string
  end
end
