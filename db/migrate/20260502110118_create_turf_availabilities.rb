class CreateTurfAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :turf_availabilities do |t|
      t.references :turf, null: false, foreign_key: true
      t.integer :day_of_week
      t.boolean :is_open
      t.time :open_time
      t.time :close_time

      t.timestamps
    end
  end
end
