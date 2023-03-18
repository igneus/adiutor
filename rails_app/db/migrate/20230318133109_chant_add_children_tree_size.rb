class ChantAddChildrenTreeSize < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :children_tree_size, :integer
  end
end
