class CreateRefreshtokens < ActiveRecord::Migration[7.0]
  def change
    create_table :refreshtokens do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :is_used, null: false

      t.timestamps
    end
  end
end
