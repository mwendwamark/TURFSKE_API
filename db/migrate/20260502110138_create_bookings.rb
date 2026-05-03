class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :turf, null: false, foreign_key: true
      t.string :reference_number
      t.date :slot_date
      t.time :start_time
      t.time :end_time
      t.decimal :duration_hours
      t.integer :amount_kes
      t.string :status
      t.text :cancel_reason
      t.string :cancelled_by

      t.timestamps
    end
  end
end
