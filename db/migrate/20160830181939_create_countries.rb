class CreateCountries < ActiveRecord::Migration[5.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.boolean :is_state_required, default: false

      t.timestamps
    end
  end
end
