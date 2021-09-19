class ChantAddVolpiano < ActiveRecord::Migration[6.1]
  def change
    add_column :chants, :volpiano, :string
  end
end
