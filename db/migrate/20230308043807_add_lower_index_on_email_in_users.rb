class AddLowerIndexOnEmailInUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, "lower(email)", unique: true
  end
end
