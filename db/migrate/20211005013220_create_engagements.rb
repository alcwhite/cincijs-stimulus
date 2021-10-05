class CreateEngagements < ActiveRecord::Migration[6.1]
  def change
    create_table :engagements do |t|
      t.string :name
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end
  end
end
