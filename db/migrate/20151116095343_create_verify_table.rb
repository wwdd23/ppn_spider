class CreateVerifyTable < ActiveRecord::Migration
  def self.up
    create_table :verifies, force: true do |table|
      table.integer :start
      table.integer :end
      table.string :command
      table.timestamps null: true
    end

    add_index :verifies, [:start, :end]
  end

  def self.down
    drop_table :verifies
  end
end
