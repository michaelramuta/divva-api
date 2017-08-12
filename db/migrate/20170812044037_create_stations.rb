class CreateStations < ActiveRecord::Migration[5.1]
  def change
    create_table :stations do |t|
      t.float :lat
      t.float :lon
      t.integer :station_id

      t.timestamps
    end
  end
end
