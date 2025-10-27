class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password
      t.float :money_spent
      t.text :bought_apps
      t.text :card_info

      t.timestamps
    end
  end
end
