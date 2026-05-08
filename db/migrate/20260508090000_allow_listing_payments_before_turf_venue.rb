class AllowListingPaymentsBeforeTurfVenue < ActiveRecord::Migration[8.0]
  def change
    change_column_null :payments, :turf_venue_id, true

    add_index :payments, :paystack_reference, unique: true, if_not_exists: true
    add_index :turf_venues, :paystack_reference, unique: true, if_not_exists: true
  end
end
