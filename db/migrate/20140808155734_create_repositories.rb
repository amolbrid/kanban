class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :url, null: false
      t.string :milestone_name
      t.string :milestone_id
      t.references :board

      t.timestamps
    end
  end
end
