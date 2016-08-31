class CreatePostcards < ActiveRecord::Migration[5.0]
  def change
    create_table :postcards do |t|
      t.string :address
      t.string :city
      t.string :zip_code
      t.text :content
      t.belongs_to :country, foreign_key: true
      t.belongs_to :state, foreign_key: {to_table: :country_states}

      t.timestamps
    end
  end
end
