class CreateParentChildMismatches < ActiveRecord::Migration[6.1]
  def change
    create_table :parent_child_mismatches do |t|
      t.belongs_to :child, table: :chants
      t.datetime :resolved_at
      t.timestamps
    end
  end
end
