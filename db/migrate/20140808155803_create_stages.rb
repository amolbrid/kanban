class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name, null: false
      t.string :github_label, null: false
      t.integer :ui_sort_order
      t.references :board

      t.timestamps
    end
  end
end
