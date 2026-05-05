class AddPlayerIdToBookingsAndReviews < ActiveRecord::Migration[8.0]
  def change
    add_reference :bookings, :player, foreign_key: { to_table: :users }
    add_reference :reviews, :player, foreign_key: { to_table: :users }
  end
end
