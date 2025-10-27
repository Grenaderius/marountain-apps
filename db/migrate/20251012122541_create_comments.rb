class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.integer :app_id
      t.integer :user_id
      t.text :comment
      t.integer :rating

      t.timestamps
    end
  end
end
