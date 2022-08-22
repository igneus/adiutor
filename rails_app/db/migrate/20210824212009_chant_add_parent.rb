class ChantAddParent < ActiveRecord::Migration[6.1]
  def change
    add_reference :chants, :parent, foreign_key: {to_table: :chants}
  end
end
