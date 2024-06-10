class ChantAddDevelopmentVersionsCount < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :development_versions_count, :integer, null: false, default: 0
  end
end
