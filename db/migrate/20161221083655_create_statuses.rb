class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :ids
      t.string :text
      t.string :created_at_time
      t.string :pic_ids
      t.string :user_ids
      t.integer :repost_count
      t.integer :comments_count
      t.integer :attitudes_count
      t.boolean :pic_mul

      t.timestamps null: false
    end
  end
end
