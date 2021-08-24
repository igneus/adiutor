class ChantAddFial < ActiveRecord::Migration[6.1]
  def change
    add_column :chants, :fial, :string
  end
end
