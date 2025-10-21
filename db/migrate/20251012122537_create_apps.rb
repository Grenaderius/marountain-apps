class CreateApps < ActiveRecord::Migration[8.0]
  def change
    create_table :apps do |t|
      t.string :name
      t.text :description
      t.boolean :is_game
      t.integer :dev_id
      t.float :cost
      t.float :size
      t.string :android_min_version
      t.string :ram_needed
      t.string :photo_path
      t.string :apk_path
      t.integer :downloads_count

      t.timestamps
    end
  end
end
