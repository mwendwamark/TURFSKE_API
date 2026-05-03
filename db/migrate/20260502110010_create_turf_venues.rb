class CreateTurfVenues < ActiveRecord::Migration[8.0]
  def change
    create_table :turf_venues do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.text :full_address
      t.string :county
      t.string :landmark
      t.decimal :latitude
      t.decimal :longitude
      t.string :contact_phone
      t.string :whatsapp_number
      t.string :contact_email
      t.string :paystack_reference
      t.string :status

      t.timestamps
    end
  end
end
