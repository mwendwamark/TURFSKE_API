class CreateAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :amenities do |t|
      t.references :turf_venue, null: false, foreign_key: true
      t.boolean :showers
      t.boolean :toilets
      t.boolean :floodlights
      t.boolean :ball_provided
      t.boolean :free_parking
      t.boolean :drinking_water
      t.boolean :bibs_vests
      t.boolean :spectator_seating
      t.boolean :canteen
      t.boolean :referee
      t.boolean :cctv
      t.boolean :wifi
      t.boolean :first_aid
      t.boolean :changing_rooms
      t.text :extra_notes

      t.timestamps
    end
  end
end
