class ChantAddTextusApprobatusNormalized < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :textus_approbatus_normalized, :text
  end
end
