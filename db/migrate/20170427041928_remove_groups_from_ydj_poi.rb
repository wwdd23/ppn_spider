class RemoveGroupsFromYdjPoi < ActiveRecord::Migration
  def change
    remove_column :ydj_pois, :groups, :string
  end
end
