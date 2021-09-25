class CreateHours < ActiveRecord::Migration[6.1]
  def change
    create_table :hours do |t|
      t.string :name
      t.string :system_name

      t.timestamps
    end

    add_belongs_to :chants, :hour
  end
end
