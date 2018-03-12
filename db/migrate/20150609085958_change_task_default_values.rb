class ChangeTaskDefaultValues < ActiveRecord::Migration
  def change
    change_column :tasks, :attempts, :integer, default: 0
    change_column :tasks, :status, :integer, default: 0
  end
end
