class ImporveTaskIndex < ActiveRecord::Migration
  def change
    #remove_index :tasks, column: [:project, :type, :status, :attempts]
    remove_index :tasks, [:project, :category, :status, :attempts]

    add_index :tasks, [:script_name, :status]
    add_index :tasks, :status
  end
end
