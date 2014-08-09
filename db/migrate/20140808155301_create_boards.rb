class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :name, null: false
      t.string :milestone
      t.boolean :is_public, null: false, default: false
      t.date :due_date
      t.string :slug
      t.references :user

      t.timestamps
    end

    add_index :boards, [:name, :user_id], unique: true
    add_index :boards, :slug, unique: true
  end
end
