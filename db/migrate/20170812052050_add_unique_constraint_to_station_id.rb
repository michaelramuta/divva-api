class AddUniqueConstraintToStationId < ActiveRecord::Migration[5.1]
  def change
  	add_index :stations, :station_id, unique: true
  end
end
