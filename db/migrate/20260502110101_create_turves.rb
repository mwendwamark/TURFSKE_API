class CreateTurves < ActiveRecord::Migration[8.0]
  def change
    create_table :turves do |t|
      t.references :turf_venue, null: false, foreign_key: true
      t.string :name
      t.string :surface_type
      t.string :pitch_format
      t.decimal :pitch_length_m
      t.decimal :pitch_width_m
      t.integer :price_per_hour
      t.integer :peak_price
      t.time :peak_from
      t.time :peak_to
      t.integer :min_booking_minutes
      t.integer :slot_duration_minutes
      t.integer :buffer_minutes
      t.boolean :auto_approve
      t.string :status

      t.timestamps
    end
  end
end
