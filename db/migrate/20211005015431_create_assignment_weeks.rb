class CreateAssignmentWeeks < ActiveRecord::Migration[6.1]
  def change
    create_table :assignment_weeks do |t|
      t.references :assignment, null: false, foreign_key: true
      t.float :max_billable_hours
      t.references :iteration, null: false, foreign_key: true
      t.date :week

      t.timestamps
    end
  end
end
