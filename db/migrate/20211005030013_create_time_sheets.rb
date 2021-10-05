class CreateTimeSheets < ActiveRecord::Migration[6.1]
  def change
    create_table :time_sheets do |t|
      t.references :person, null: false, foreign_key: true
      t.date :start_date

      t.timestamps
    end
  end
end
