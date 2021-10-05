class CreateIterations < ActiveRecord::Migration[6.1]
  def change
    create_table :iterations do |t|
      t.date :week
      t.references :engagement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
