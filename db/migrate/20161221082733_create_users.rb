class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :ids
      t.string :screen_name
      t.string :name
      t.string :location
      t.integer :city
      t.integer :province
      t.string :description
      t.string :profile_image_url
      t.integer :followers_count
      t.integer :friends_count
      t.integer :statuses_count
      t.boolean :sex

      t.timestamps null: false
    end
  end
end
