class CreateProxies < ActiveRecord::Migration
  def change
    create_table :proxies do |t|
      t.string :ip
      t.integer :port
      t.integer :proxy_type
      t.string :status

      t.timestamps
    end
  end
end
