class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :url
      t.string :script_name
      t.integer :status
      t.integer :attempts
      t.string :project
      t.integer :type
      t.timestamps
    end

    add_index :tasks, [:project, :type, :status, :attempts]
  end
end
