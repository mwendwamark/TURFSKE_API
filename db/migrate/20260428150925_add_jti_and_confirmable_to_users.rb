class AddJtiAndConfirmableToUsers < ActiveRecord::Migration[8.0]
  def change
    # Add JTI for JWT revocation
    add_column :users, :jti, :string
    add_index :users, :jti, unique: true

    # Add confirmable fields
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true

    # Change role from string to string array (using PostgreSQL array)
    remove_column :users, :role, :string
    add_column :users, :roles, :string, array: true, default: []

    # Generate JTI for existing users
    User.reset_column_information
    User.find_each do |user|
      user.update_column(:jti, SecureRandom.uuid) if user.jti.blank?
    end
  end
end
