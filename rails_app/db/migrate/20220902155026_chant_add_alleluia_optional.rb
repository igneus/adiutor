class ChantAddAlleluiaOptional < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :alleluia_optional, :boolean
  end
end
