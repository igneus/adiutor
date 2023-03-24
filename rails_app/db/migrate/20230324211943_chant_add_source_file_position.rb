class ChantAddSourceFilePosition < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :source_file_position, :integer
  end
end
