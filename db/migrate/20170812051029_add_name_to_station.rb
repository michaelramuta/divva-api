class AddNameToStation < ActiveRecord::Migration[5.1]
  def change
  	add_column :stations, :name, :string
  end
end
