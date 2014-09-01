class ChangeDesTypeInFoodies < ActiveRecord::Migration
  def change
    change_column :foodies, :description, :text
  end
end
