class AddRides < ActiveRecord::Migration[5.1]
  def change
  	create_table :rides do |t|
      t.integer :station_1_id
      t.integer :station_2_id
      t.float :distance

      t.timestamps
    end
  end
end
