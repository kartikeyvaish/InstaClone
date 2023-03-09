class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :caption
      t.string :image, null: false
      t.string :location
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
