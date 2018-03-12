class AddScriptNameIndex < ActiveRecord::Migration
  def change
    add_index :tasks, [:script_name]
    add_index :tasks, [:category]
    add_index :tasks, [:created_at]
  end
end
