class ChantAddAmbitusAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :ambitus_min_note, :string, limit: 1
    add_column :chants, :ambitus_max_note, :string, limit: 1
    add_column :chants, :ambitus_interval, :integer
  end
end
