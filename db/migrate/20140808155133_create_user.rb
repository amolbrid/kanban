class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name, null: false
      t.string :nickname
      t.string :email
      t.string :image_url
      t.string :token
    end
  end
end
