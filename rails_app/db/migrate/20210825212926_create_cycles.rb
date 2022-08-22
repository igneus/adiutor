class CreateCycles < ActiveRecord::Migration[6.1]
  def change
    create_table :cycles do |t|
      t.string :name
      t.string :system_name

      t.timestamps
    end

    add_belongs_to :chants, :cycle
  end
end
