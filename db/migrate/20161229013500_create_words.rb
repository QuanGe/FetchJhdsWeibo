class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :text
      t.string :level

      t.timestamps null: false
    end
  end
end
