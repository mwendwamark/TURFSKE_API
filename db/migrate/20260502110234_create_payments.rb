class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :turf_venue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :payment_type
      t.integer :amount_kobo
      t.string :currency
      t.string :paystack_reference
      t.string :paystack_transaction_id
      t.string :channel
      t.string :status
      t.jsonb :paystack_metadata
      t.string :paid_at

      t.timestamps
    end
  end
end
