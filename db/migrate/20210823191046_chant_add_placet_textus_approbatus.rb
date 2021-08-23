class ChantAddPlacetTextusApprobatus < ActiveRecord::Migration[6.1]
  def change
    change_table :chants do |t|
      t.string :placet
      t.text :textus_approbatus
    end
  end
end
