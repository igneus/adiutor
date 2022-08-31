class ChantAddSimpleCopy < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :simple_copy, :boolean, null: false, default: false
  end
end
