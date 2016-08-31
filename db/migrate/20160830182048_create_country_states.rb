class CreateCountryStates < ActiveRecord::Migration[5.0]
  def change
    create_table :country_states do |t|
      t.belongs_to :country, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
