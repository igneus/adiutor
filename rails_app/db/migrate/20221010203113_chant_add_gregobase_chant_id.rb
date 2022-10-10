class ChantAddGregobaseChantId < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :gregobase_chant_id, :integer
  end
end
