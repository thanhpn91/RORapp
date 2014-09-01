class CreateFoodies < ActiveRecord::Migration
  def change
    create_table :foodies do |t|
      t.string :title
      t.string :address
      t.string :description
      t.string :photos
      t.integer :category

      t.timestamps
    end
  end
end
