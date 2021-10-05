class CreateTimeEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :time_entries do |t|
      t.date :date
      t.references :time_sheet, null: false, foreign_key: true
      t.references :assignment_week, null: false, foreign_key: true
      t.float :time_amount

      t.timestamps
    end
  end
end
