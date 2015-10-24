class AddMoveIssuesColumnToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :move_other_issues, :boolean, null: false, default: true
    add_column :boards, :move_closed_issues, :boolean, null: false, default: true
  end
end
