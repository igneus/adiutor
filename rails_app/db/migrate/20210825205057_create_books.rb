class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :name
      t.string :system_name

      t.timestamps
    end

    add_belongs_to :chants, :book
  end
end
