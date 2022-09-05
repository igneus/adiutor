class ChantAddCopy < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :copy, :boolean, null: false, default: false
  end
end
